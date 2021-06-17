use strict;

my %f;
while(<>){
    chomp;
    my $id=(split/\t/)[0]; 
    while(/(GO:\d+)/g){
        push @{$f{$1}},$id;
    }
}

my %r;
for my $go (sort keys %f){ 
    for my $gene (@{$f{$go}}){
        $r{"$go\,$gene"}++;
    }
}

open O,">bg_go.csv";
for my $item (sort keys %r){
    print O "$item\n";
}
