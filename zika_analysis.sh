#!/bin/bash

# get the data
wget -q http://s3.climb.ac.uk/nanopore/Zika_MP1751_PHE_Long_R9_2D.tgz

# surprise, it's not zipped
tar xvf Zika_MP1751_PHE_Long_R9_2D.tgz

# extract 2D FASTQ
extract2D Zika_MP1751_PHE_Long_R9_2D/downloads_rnn_wf839/pass/ > zika.pass.2D.fastq 
extract2D Zika_MP1751_PHE_Long_R9_2D/downloads_rnn_wf839/fail/ > zika.fail.2D.fastq 

# convert to FASTA
porefq2fa zika.pass.2D.fastq > zika.pass.2D.fasta
porefq2fa zika.fail.2D.fastq > zika.fail.2D.fasta

# read lengths
cat zika.pass.2D.fastq | paste - - - - | awk '{print $3}' | awk '{print length($1)}' > zika.pass.2D.readlengths.txt

# extract metadata
extractMeta Zika_MP1751_PHE_Long_R9_2D/downloads_rnn_wf839/pass/ > zika.pass.meta.txt
extractMeta Zika_MP1751_PHE_Long_R9_2D/downloads_rnn_wf839/fail/ > zika.fail.meta.txt

# bwa index the genome
bwa index zika_genome.fa

# samtools index the genome
samtools faidx zika_genome.fa

# run bwa and pipe straight to samtools to create BAM
bwa mem -M -x ont2d zika_genome.fa zika.pass.2D.fastq | \
        samtools view -T zika_genome.fa -bS - | \
        samtools sort -T zika.pass_vs_zika_genome.bwa -o zika.pass_vs_zika_genome.bwa.bam -

samtools index zika.pass_vs_zika_genome.bwa.bam

# create a LAST db of the reference genome
lastdb zika_genome zika_genome.fa

# align high quaklity reads to reference genome with LAST
lastal -q 1 -a 1 -b 1 zika_genome zika.pass.2D.fasta > zika.pass_vs_zika_genome.maf

# convert the MAF to BAM with complete CIGAR (matches and mismatches)
python nanopore-scripts/maf-convert.py sam zika.pass_vs_zika_genome.maf | \
    samtools view -T zika_genome.fa -bS - | \
    samtools sort -T zika.pass_vs_zika_genome.last -o zika.pass_vs_zika_genome.last.bam -

samtools index zika.pass_vs_zika_genome.last.bam

# count errors
python nanopore-scripts/count-errors.py zika.pass_vs_zika_genome.last.bam > zika.pass_vs_zika_genome.last.txt

# produce consensus
samtools mpileup -vf zika_genome.fa zika.pass_vs_zika_genome.bwa.bam | bcftools call -m -O z - > allsites.vcf.gz
bcftools index allsites.vcf.gz
bcftools consensus -f zika_genome.fa allsites.vcf.gz > zika.minion.consensus.fasta

# QC images
./scripts/qc.R
