use Excel::Writer::XLSX;
use File::Basename qw(basename dirname);
use Text::CSV;

#convert all csv format file to xlsx format file in a directory
my @in=<*.csv>;

for my $in (@in){
#my $in=shift;
    my ($name)=basename $in=~/(\S+).csv/;

    my $csv = Text::CSV->new({ sep_char => ', ' });

    my $Excel_book  = Excel::Writer::XLSX->new("$name.xlsx");
    my $Excel_sheet = $Excel_book->add_worksheet();

    open IN ,"$in";
    my $row=1;
    while(my $line = <IN>){
        chomp $line;
        if ($csv->parse($line)){
            my @info = $csv->fields();
            $Excel_sheet->write("A$row",\@info);
        }else{
            warn "Line could not be parsed: $line\n";
        }
        $row++;
    }
    close IN;
    $Excel_book->close;
}
