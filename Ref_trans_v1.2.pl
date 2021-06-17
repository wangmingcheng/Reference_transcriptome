use strict;
use warnings;
use File::Basename qw(basename dirname);
use Cwd qw(abs_path getcwd);
use FindBin qw($Bin $Script);
use Getopt::Long;
use lib "$Bin/config/";
use newPerlBase;

my %config=%{readconf("$Bin/config/db_file.cfg")};

my $od=$ENV{PWD};
`mkdir -p $od/00.data_clean` unless (-d "$od/00.data_clean");
`mkdir -p $od/01.genome_index` unless (-d "$od/01.genome_index");
`mkdir -p $od/02.hisat2_samtools` unless (-d "$od/02.bwa_samtools");
`mkdir -p $od/03.stringtie_assembly` unless (-d "$od/03.stringtie_assembly");
`mkdir -p $od/04.count_matrices` unless (-d "$od/04.count_matrices");
`mkdir -p $od/05.differential_expression_gene` unless (-d "$od/05.differential_expression_gene");
my $data=shift;
open (IN,$data) or die $!;
my %seq_hash;

my $sample;
my $genome;
my $gff;
my %deg;
open (INDEX, ">$od/01.genome_index/hisat2-build.sh");
while (<IN>){
    chomp;
    next if /^$/ || /^\#/;
    my @data=split /\s+/, $_;
    if ($data[0]=~/Genome/i){
        $genome=basename($data[1]);
        print INDEX "cd $od/01.genome_index && `cp $data[1] .` && $config{'hisat2-build'} -p 10 $od/01.genome_index/$genome $od/01.genome_index/$genome\n";
    }elsif($data[0]=~/GFF/i){
        $gff=basename($data[1]);
        print INDEX "`cp $data[1] $od/01.genome_index/`","\n";
    }elsif($data[0]=~/group/i){
        $deg{$data[0]}{$data[1]}=$data[2];
    }else{

        $sample=$data[0];
        my $rep=$data[1];
        
        $seq_hash{$rep}{fq1}=$data[2];
        $seq_hash{$rep}{fq2}=$data[3];
    }
}
open (FASTP,">$od/00.data_clean/fastp.sh") or die $!;

open (ALN,">$od/02.hisat2_samtools/hisat2_samtools.sh");

open (ASSEMBLY,">$od/03.stringtie_assembly/stringtie_assembly.sh");

foreach my $samp (sort keys %seq_hash){
    chomp $samp;
    `mkdir -p $od/00.data_clean/$samp` unless (-d "$od/00.data_clean/$samp");
    print FASTP "cd $od/00.data_clean/$samp && $config{fastp} -i $seq_hash{$samp}{fq1} -I $seq_hash{$samp}{fq2} -o $samp\_clean.1.fq.gz -O $samp\_clean.2.fq.gz --thread 7 --json $samp.json --html $samp.html\n";
    print ALN "$config{hisat2} -p 15 --dta -x $od/01.genome_index/$genome -1 $od/00.data_clean/$samp/$samp\_clean.1.fq.gz -2 $od/00.data_clean/$samp/$samp\_clean.2.fq.gz | $config{samtools} view -bS -@ 10 | $config{samtools} sort -@ 10 -o $od/02.hisat2_samtools/$samp\_sorted.bam && samtools index -@ 10 $od/02.hisat2_samtools/$samp\_sorted.bam && $config{samtools} flagstat -@ 10 $od/02.hisat2_samtools/$samp\_sorted.bam > $od/02.hisat2_samtools/$samp\_alignment_stat\n";
    `mkdir -p $od/03.stringtie_assembly/$samp` unless (-d "$od/03.stringtie_assembly/$samp");
    print ASSEMBLY "cd $od/03.stringtie_assembly/$samp && $config{stringtie} $od/02.hisat2_samtools/$samp\_sorted.bam -G $od/01.genome_index/$gff -p 10 -o $od/03.stringtie_assembly/$samp/$samp.gtf -e -B -A $od/03.stringtie_assembly/$samp/$samp.tab -l $samp && cd -\n";
}


open (CM,">$od/04.count_matrices/count_matrices.sh");
print CM "$config{'prepDE.py3'} -i $od/03.stringtie_assembly -g $od/04.count_matrices/gene_count_matrix.csv -t $od/04.count_matrices/transcript_count_matrix.csv -l 147\n";

open DE,">$od/05.differential_expression_gene/DEG.sh";
for my $group (sort keys %deg){
    open O,">$od/05.differential_expression_gene/$group";
    print O "sample condition\n";
    my ($samp1,$samp2);
    for my $de (sort keys %{$deg{$group}}){
        ($samp1,$samp2)=split/\;|\s+/,$de;
        my ($control,$case)=split/\;|\s+/,$deg{$group}{$de};
        my @a=split/\,|\s+/,$control;
        my @b=split/\,|\s+/,$case;
        for my $a (@a){
            print O "$a $samp1\n";
        }
        for my $b (@b){
            print O "$b $samp2\n";
        }                                                        
    }
    `mkdir $od/05.differential_expression_gene/$samp1\_VS\_$samp2` unless (-d "$od/05.differential_expression_gene/$samp1\_VS\_$samp2"); 
    print DE "cd $od/05.differential_expression_gene/$samp1\_VS\_$samp2 && Rscript $Bin/bin/DEG.r $od/04.count_matrices/gene_count_matrix.csv $od/05.differential_expression_gene/$group $samp1\_VS\_$samp2 && perl $Bin/script/deseq2_csv2xlsx.pl $samp1\_VS\_$samp2.csv && perl $Bin/script/deseq2_csv2xlsx.pl $samp1\_VS\_$samp2\_DE.csv && perl $Bin/script/deseq2_csv2xlsx.pl $samp1\_VS\_$samp2\_DE.counts.csv && python  $Bin/bin/pdf2png.py && cd -\n";
}

`mkdir -p $od/work.sh` unless (-d "$od/work.sh");
`cd $od/work.sh/ && ln -s ../*/*sh .`;

open ST,">$od/work.sh/stat.sh";
print ST "cd $od/00.data_clean && perl $Bin/script/reads_stat.pl && cd -\n";
print ST "cd $od/02.hisat2_samtools && perl $Bin/script/stat_alignment.pl && cd -\n";

=c
forkOrDie("$od/00.data_clean/fastp.sh",10);
system("sh $od/01.genome_index/hisat2-build.sh");
forkOrDie("$od/02.hisat2_samtools/hisat2_samtools.sh",10);
system("sh $od/work.sh/stat.sh");
forkOrDie("$od/03.stringtie_assembly/stringtie_assembly.sh",10);
system ("sh $od/04.count_matrices/count_matrices.sh");
forkOrDie("$od/05.differential_expression_gene/DEG.sh",3);
