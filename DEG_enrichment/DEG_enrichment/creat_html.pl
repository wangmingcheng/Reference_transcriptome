use strict;
use File::Basename qw(dirname basename);
my @group=<./*>;
for my $group (@group){
    next unless (-d $group);
    my $name=basename $group;
    open O,">$name\_DE_analyse.html";
    open IN,"../template.html";
    while(<IN>){
        print O "$_";
    }
    close IN;

    print O "<\/style><title>$name-差异表达基因富集分析<\/title>\n";
    print O "<\/head>\n";
    print O "<body class=\'typora-export os-windows\'><div class=\'typora-export-content\'>\n";
    print O "<div id=\'write\'  class=\'\'><h3 id=\'差异表达基因富集分析\'><span>差异表达基因富集分析<\/span><\/h3><p><span>差异表达基因<\/span><a href=\'$name\\$name\_go_enrichment.xlsx\'><span>GO富集列表<\/span><\/a><\/p><p><span>富集GO<\/span><\/p><p><img src=\"$name\\$name\_go_enrichment_barplot.png\" alt=\"$name\_go_enrichment_barplot\" style=\"zoom: 25%\;\"  \/><\/p><p><span>Dotplot<\/span><\/p><p><img src=\"$name\\$name\_go_enrichment_dotplot.png\" alt=\"$name\_go_enrichment_barplot\" style=\"zoom:25%\;\" \/><\/p><p><span>cnetplot<\/span><\/p><p><img src=\"$name\\$name\_go_enrichment_cnetplot.png\" style=\"zoom: 33%\;\" \/><\/p><p><span>差异表达基因kegg<\/span><a href=\'$name\\$name\_kegg_enrichment.xlsx\'><span>富集列表<\/span><\/a>";
    my @pathway_info=<$group/*html>;
    for my $pathway_info (@pathway_info){
        my ($pathway)=basename $pathway_info=~/(\S+?).html/;
        print O "<\/p><p><span>富集通路-$pathway<\/span><\/p><p><img src=\"$name\\$pathway.$name.png\" alt=\"$pathway.$name\" style=\"zoom: 80%\;\" \/><\/p><p><a href=\'https:\/\/www.genome.jp\/pathway\/$pathway\'><span>web<\/span><\/a>";
    } 
    print O "<\/p><p>&nbsp\;<\/div><\/div>\n<\/body>\n<\/html>"; 
}
=c
</style><title>差异表达基因富集分析</title>
</head>
<body class='typora-export os-windows'><div class='typora-export-content'>
<div id='write'  class=''><h3 id='差异表达基因富集分析'><span>差异表达基因富集分析</span></h3><p><span>差异表达
基因GO</span><a href='C_VS_A\C_VS_A_go_enrichment.xlsx'><span>富集列表</span></a></p><p><span>富集GO</span></p><p><img src="C:\Users\wangm\Desktop\DEG_enrichment\C_VS_A\C_VS_A_go_enrichment_barplot.png" alt="C_VS_A_go_enrichment_barplot" style="zoom: 25%;" /></p><p><span>Dotplot</span></p><p><img src="C:\Users\wangm\Desktop\DEG_enrichment\C_VS_A\C_VS_A_go_enrichment_dotplot.png" alt="C_VS_A_go_enrichment_dotplot" style="zoom:25%;" /></p><p><span>cnetplot</span></p><p><img src="C:\Users\wangm\Desktop\DEG_enrichment\C_VS_A\C_VS_A_go_enrichment_emapplot.png" style="zoom: 33%;" /></p><p><span>差异表达基因kegg</span><a href='C_VS_A\C_VS_A_kegg_enrichment.xlsx'><span>富集列表</span></a></p><p><span>富集通路</span></p><p><img src="C:\Users\wangm\Desktop\DEG_enrichment\C_VS_A\cic00196.C_VS_A.png" alt="cic00196.C_VS_A" style="zoom: 80%;" /></p><p><a href='https://www.genome.jp/pathway/cic00196'><span>web</span></a></p><p>&nbsp;</p></div></div>
</body>
</html>
