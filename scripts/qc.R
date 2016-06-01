#!/usr/bin/env Rscript

suppressMessages(suppressWarnings(library(poRe)))

pmeta <- read.table("zika.pass.meta.txt", header=TRUE, sep="\t", stringsAsFactors=FALSE)

png("raw.pass.read.length.png", width=2400, height=800)
plot.length.histogram(pmeta[pmeta$len2d<12000&pmeta$len2d>0,])
suppressMessages(suppressWarnings(dev.off()))

png("pass.cumulative.yield.png", width=2400, height=800)
yield <- plot.cumulative.yield(pmeta)
suppressMessages(suppressWarnings(dev.off()))

d <- read.table("zika.pass_vs_zika_genome.last.txt", header=TRUE)
png("mapped.read.length.png", width=800, height=800)
hist(d$read_len, breaks=100, col="red", main="Mapped read length", xlab="Read Length")
suppressMessages(suppressWarnings(dev.off()))

pid <- 100 * d$matches / (d$matches + d$deletions + d$insertions + d$mismatches)
png("mapped.error.rate.png", width=800, height=800)
hist(pid, breaks=100, col="red", main="Mapped error rate", xlab="Percentage ID")
suppressMessages(suppressWarnings(dev.off()))

