use strict;
use File::Basename qw(basename dirname);

#my $bg="/home/haijie/project/citrus/Cclementina/bg_gene_go.txt";
#my $tool="/home/haijie/project/citrus/ref_trans/bin/go_enrichment.r";
my @DEG=<..//05.differential_expression_gene/*DE.csv>;
open O,">go_enrichment.sh";
for my $deg (@DEG){
	my $name=(split/\./,basename($deg))[0];
	print O "Rscript enrichment.r $deg $name\n";
}
`parallel -j 14 <go_enrichment.sh`;

