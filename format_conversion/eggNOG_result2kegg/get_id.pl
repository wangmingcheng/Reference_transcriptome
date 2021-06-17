
open IN,"GCF_001858045.2_O_niloticus_UMD_NMBU_translated_cds.faa";
my %f;
while(<IN>){
	chomp;
	next unless /^>/;
	my ($idinfo,$gene_info)=(split/\s+/,$_)[0,1];
	my ($id)=$idinfo=~/>(\S+)/;
	my ($gene)=$gene_info=~/\[gene=(\S+)\]/;
	$f{$id}=$gene;
}

my %h;
while(<>){
	chomp;
    next if /^#/;
	my @info=split/\s+/,$_,2;
    #print "$f{$info[0]}\t$info[1]\n";
	#print "$f{$info[1]}\t$info[0]\n";
    while($_=~/(GO:\d+)/g){
        push @{$h{$1}},$f{$info[0]}
    }
}

my %u;
for my $go (sort keys %h){
    $u{"$go\,$_"}++ for @{$h{$go}};
}

for my $item (sort keys %u){
    print "$item\n";
} 

sub uniq{
    my %seen;
    return grep {!$seen{$_}} @_;
}
