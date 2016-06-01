# Analysis of public ZiBRA data

[Data](http://zibraproject.github.io/data/) became available from the [ZiBRA](http://zibraproject.github.io/) project yesterday, incliding a 47.9Gb tar archive of MinION data.

This repo provides a script to download and analyse that data including:

* FASTQ/A extraction
* Run metadata extraction including read length and quality
* Mapping to reference
* Consensus generation

You will need:

* This repo
* [poRe 0.17](https://github.com/mw55309/poRe_docs)
* [poRe shell scripts](https://github.com/mw55309/poRe_scripts)
* samtools (I used version 1.2)
* bcftools (I used version 1.2)
* R (I used version 3.1)

Questions to mick.watson@roslin.ed.ac.uk
