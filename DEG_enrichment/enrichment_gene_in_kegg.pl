use strict;
use warnings;
use File::Basename qw(basename dirname);

open I,"/data03/home/wangmingcheng/All_Plants.gene_info";
my %f;
while(<I>){
    chomp;
    my @info=split/\s+/,$_;
    $f{$info[2]}=$info[1];
}
close I;
my @DE_info=</data03/home/wangmingcheng/test/05.differential_expression_gene/*_DE.csv>;
mkdir "DEG_enrichment" unless (-d "DEG_enrichment");
open CM,">DEG_enrichment/enrichment.sh";
for my $DE_info(@DE_info){
	open IN,"$DE_info";
	my ($name) = basename ($DE_info) =~/(\S+?)\_DE.csv/;
	`mkdir -p DEG_enrichment/$name` unless (-d "DEG_enrichment/$name");
    open O,">DEG_enrichment/$name/$name.csv";
	print O "ID\,Symbol\,log2FoldChange\,padj\n";
	while(<IN>){
		chomp;
		my @info=split/\,/,$_;
		next unless $info[0]=~/LOC/;
		my ($symbol)=$info[0]=~/(LOC\d+)/;
        print O "$f{$symbol}\,$symbol\,$info[2]\,$info[-1]\n" if $f{$symbol};
    }
    close IN;
    print CM "cd DEG_enrichment/$name && Rscript /data03/home/wangmingcheng/pipeline/ref_trans/DEG_enrichment/enrichment.r $name.csv $name && perl /data03/home/wangmingcheng/pipeline/ref_trans/script/deseq2_csv2xlsx.pl $name\_kegg_enrichment.csv && perl /data03/home/wangmingcheng/pipeline/ref_trans/script/deseq2_csv2xlsx.pl $name\_go_enrichment.csv && cd -\n";
}
