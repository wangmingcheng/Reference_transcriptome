#use strict;
use JSON;
use Encode;
use File::Basename qw(basename dirname);
use Excel::Writer::XLSX;

my $workbook  = Excel::Writer::XLSX->new('reads_stat.xlsx');
my $rawsheet = $workbook->add_worksheet("raw_reads");
my $cleansheet = $workbook->add_worksheet("clean_reads");

my @header=("sample","total_reads","total_bases","q20_bases","q30_bases","q20_rate","q30_rate","read1_mean_length","read2_mean_length","gc_content");
$rawsheet->write(A1,\@header);
$cleansheet->write(A1,\@header);

open R,">raw_data_stats.csv";
print R "sample\,total_reads\,total_bases\,q20_bases\,q30_bases\,q20_rate\,q30_rate\,read1_mean_length\,read2_mean_length\,gc_content\n";

open C,">clean_data_stats.csv";

print C "sample\,total_reads\,total_bases\,q20_bases\,q30_bases\,q20_rate\,q30_rate\,read1_mean_length\,read2_mean_length\,gc_content\n";

my $line=2;
my @json=<*/*json>;
    for my $json (@json){
    my $sample=dirname $json;
    my $text;
    open IN,"$json";
    while(<IN>){
        chomp;
        $text.=$_;
    }
    close IN;
    my $obj=decode_json($text);
    print R "$sample\,";
    my $raw_total_reads=$obj->{"summary"}->{"before_filtering"}->{"total_reads"};
    print R $obj->{"summary"}->{"before_filtering"}->{"total_reads"},",";
    my $raw_total_bases=$obj->{"summary"}->{"before_filtering"}->{"total_bases"};
    print R $obj->{"summary"}->{"before_filtering"}->{"total_bases"},",";
    my $raw_q20_bases=$obj->{"summary"}->{"before_filtering"}->{"q20_bases"};
    print R $obj->{"summary"}->{"before_filtering"}->{"q20_bases"},",";
    my $raw_q30_bases=$obj->{"summary"}->{"before_filtering"}->{"q30_bases"};
    print R $obj->{"summary"}->{"before_filtering"}->{"q30_bases"},",";
    my $raw_q20_rate=$obj->{"summary"}->{"before_filtering"}->{"q20_rate"};
    print R $obj->{"summary"}->{"before_filtering"}->{"q20_rate"},",";
    my $raw_q30_rate=$obj->{"summary"}->{"before_filtering"}->{"q30_rate"};
    print R $obj->{"summary"}->{"before_filtering"}->{"q30_rate"},",";
    my $raw_read1_mean_length=$obj->{"summary"}->{"before_filtering"}->{"read1_mean_length"};
    print R $obj->{"summary"}->{"before_filtering"}->{"read1_mean_length"},",";
    my $raw_read2_mean_length=$obj->{"summary"}->{"before_filtering"}->{"read2_mean_length"};
    print R $obj->{"summary"}->{"before_filtering"}->{"read2_mean_length"},",";
    my $raw_gc_content=$obj->{"summary"}->{"before_filtering"}->{"gc_content"};
    print R $obj->{"summary"}->{"before_filtering"}->{"gc_content"},"\n";
    my @raw_content = ($sample,$raw_total_reads,$raw_total_bases,$raw_q20_bases,$raw_q30_bases,$raw_q20_rate,$raw_q30_rate,$raw_read1_mean_length,$raw_read2_mean_length,$raw_gc_content);
    $rawsheet->write("A$line",\@raw_content);
    
    print C "$sample\,";
    my $clean_total_reads=$obj->{"summary"}->{"after_filtering"}->{"total_reads"};
    print C $obj->{"summary"}->{"after_filtering"}->{"total_reads"},",";
    my $clean_total_bases=$obj->{"summary"}->{"after_filtering"}->{"total_bases"};
    print C $obj->{"summary"}->{"after_filtering"}->{"total_bases"},",";
    my $clean_q20_bases=$obj->{"summary"}->{"after_filtering"}->{"q20_bases"};
    print C $obj->{"summary"}->{"after_filtering"}->{"q20_bases"},",";
    my $clean_q30_bases=$obj->{"summary"}->{"after_filtering"}->{"q30_bases"};
    print C $obj->{"summary"}->{"after_filtering"}->{"q30_bases"},",";
    my $clean_q20_rate=$obj->{"summary"}->{"after_filtering"}->{"q20_rate"};
    print C $obj->{"summary"}->{"after_filtering"}->{"q20_rate"},",";
    my $clean_q30_rate=$obj->{"summary"}->{"after_filtering"}->{"q30_rate"};
    print C $obj->{"summary"}->{"after_filtering"}->{"q30_rate"},",";
    my $clean_read1_mean_length=$obj->{"summary"}->{"after_filtering"}->{"read1_mean_length"};
    print C $obj->{"summary"}->{"after_filtering"}->{"read1_mean_length"},",";
    my $clean_read2_mean_length=$obj->{"summary"}->{"after_filtering"}->{"read2_mean_length"};
    print C $obj->{"summary"}->{"after_filtering"}->{"read2_mean_length"},",";
    my $clean_gc_content=$obj->{"summary"}->{"after_filtering"}->{"gc_content"};
    print C $obj->{"summary"}->{"after_filtering"}->{"gc_content"},"\n";
    my @clean_content=($sample,$clean_total_reads,$clean_total_bases,$clean_q20_bases,$clean_q30_bases,$clean_q20_rate,$clean_q30_rate,$clean_read1_mean_length,$clean_read2_mean_length,$clean_gc_content);
    $cleansheet->write("A$line",\@clean_content);
    $line++;
}
close R;
close C;
$workbook->close();
