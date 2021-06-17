use warnings;
use File::Basename qw(basename dirname);
use Excel::Writer::XLSX;

#T06_GCA_002525835.2_ipoBat4_alignment_stat
#36737790 + 0 mapped (76.97% : N/A)
my $workbook  = Excel::Writer::XLSX->new('sample_mapping_stat.xlsx');
my $mappingsheet = $workbook->add_worksheet("mapping_rate");

my @header=(Sample,'Mapped Reads(%)','Properly paired(%)');
$mappingsheet->write("A1",\@header);

my @in = <*stat>;
open O, ">sample_mapping_stat.csv";
print O 'Sample,Mapped Reads(%),Properly paired(%)',"\n";
my $line=2;
for my $in (@in){
    my $name = basename $in;
    my @content;
    my ($sample) = $name =~ /(\S+?)\_alignment\_stat/;
    open IN, "$in";
    push @content,$sample;
    while(<IN>){
        chomp;
        print O "$sample\,$1\," if /mapped \((\S+?)%/;
        push @content, $1 if /mapped \((\S+?)%/;
        print O "$1\n" if /properly paired \((\S+?)%/;
        push @content, $1 if /properly paired \((\S+?)%/;
    }
    $mappingsheet->write("A$line",\@content); 
    close IN;
    $line++;
}
$workbook->close();
