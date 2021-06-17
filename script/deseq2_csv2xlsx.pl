use warnings;
use File::Basename qw(basename dirname);
use Excel::Writer::XLSX;

my $csv=shift;
my ($name)=$csv=~/(\S+?).csv/;
my $workbook  = Excel::Writer::XLSX->new("$name.xlsx");
my $sheet = $workbook->add_worksheet("$name");

#my @header=("geneID","baseMean","log2FoldChange","lfcSE","stat","pvalue","padj");
#$sheet->write("A1",\@header);
open IN,"$csv";
my $line=1;
while(<IN>){
    chomp;
    my @row=split/\,/,$_;
    #@row=unshift @row,"geneID" if ($.==1);    
    $sheet->write("A$line",\@row); 
    $line++;
}
close IN;
$workbook->close();
