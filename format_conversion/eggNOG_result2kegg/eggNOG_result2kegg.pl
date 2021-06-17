use strict;
use warnings;

use strict;
use warnings;

my %f;
while(<>){
    next if /^#/;
    my ($gene,$K,$ko_info)=(split/\t/,$_)[0,11,12];
    my @k;
    push @k,$1 if($K=~/ko:(K\d+)/g);
    while($ko_info=~/(ko\d+)/g){
        push @{$f{$1}},$_ for @k;
    }
}
my %h;

for my $ko (sort keys %f){
    $h{"$ko\,$_"}++ for @{$f{$ko}};
}
open O,">bg_kegg.csv";
for my $item (sort keys %h){
    print O "$item\n";
}


=c
my %f;
while(<>){
    next if /^#/;
    my ($gene,$ko_info)=(split/\t/,$_)[0,12];
    while($ko_info=~/(ko\d+)/g){
        push @{$f{$1}},$gene;
    }
}
my %h;

for my $ko (sort keys %f){
    $h{"$ko\t$_"}++ for @{$f{$ko}};
}

for my $item (sort keys %h){
    print "$item\n";
}

sub uniq{
    my %count;
    return grep {!$count{$_}} @_;
}
