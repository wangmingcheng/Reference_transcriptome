# Reference_transcriptome
perl Ref_trans_v1.3.pl sample_file.config
## 转录组定量
### featureCounts: https://subread.sourceforge.net/featureCounts.html<br>
featureCounts -a Canis_lupus_familiaris.ROS_Cfam_1.0.108.gtf -o gene_counts.txt -T 20 -t gene -f -p *bam<br>
RSEM: https://github.com/deweylab/RSEM<br>
salmon：https://github.com/COMBINE-lab/salmon<br>
HTSeq: https://github.com/htseq/htseq/blob/master/doc/index.rst<br>

