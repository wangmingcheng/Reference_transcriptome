use strict;
use File::Basename qw(dirname basename);
use FindBin qw($Bin $Script);

my @group=<./*>;
for my $group (@group){
    next unless (-d $group);
    my $name=basename $group;
    open O,">$name\_DE_enrichment.html";
    open IN,"$Bin/enrichment.template";
    while(<IN>){
        print O "$_";
    }
    close IN;
    open I, "$group/$name\_kegg_enrichment.csv";
    my %f;
    while(<I>){
        chomp;
        my ($pathinfo,$idinfo)=(split/\,/,$_)[1,8];
        my ($path)=$pathinfo=~/\"(\S+)\"/;
        my ($ids)=$idinfo=~/\"(\S+)\"/;
        $f{$path}=$ids;
    }
    close I;

    print O "<\/style><title>$name-差异表达基因富集分析<\/title>\n";
    print O "<\/head>\n";
    print O "<body class=\'typora-export os-windows\'><div class=\'typora-export-content\'>\n";
    print O "<div id=\'write\'  class=\'\'><h3 id=\'差异表达基因富集分析\'><span>差异表达基因富集分析<\/span><\/h3><h4 id=\'差异表达基因go富集列表\'><span>差异表达基因<\/span><a href=\'$name\\$name\_go_enrichment.xlsx\'><span>GO富集列表<\/span><\/a><\/h4><p><span>条形图(Bar Plot)是应用最广泛的富集条目展示工具\,下图选取了GO富集中P值最显著的20个条目(横坐标即条形的长度表示富集到GO条目上的差异基因的数量\,纵坐标代表GO条目的功能表述\,颜色代表显著性\,全部的GO富集信息\,可查看上述GO富集列表)<\/span><\/p><p><img
    src=\"$name\\$name\_go_enrichment_barplot.png\" alt=\"$name\_go_enrichment_barplot\" style=\"zoom: 25%\;\"  \/><\/p><p><span>点图(Dot plot)展示的信息和条形图类似(横坐标代表前景基因的比例\,即富集到GO条目上的差异基因占总差异基因的比例\,纵坐标同条形图)<\/span><\/p><p><img src=\"$name\\$name\_go_enrichment_dotplot.png\" alt=\"$name\_go_enrichment_barplot\"
    style=\"zoom:25%\;\" \/><\/p><p><span>cnetplot\,条形图和点图只可以展示富集到的条目的信息\,作为补充cneplot可以显示有哪些基因和我们富集到的GO条目相关(中心的圈的大小代表富集到条目的差异基因的数量\,与之相连点的颜色代表差异基因是上调下调和其程度)<\/span><\/p><p><img src=\"$name\\$name\_go_enrichment_cnetplot.png\" style=\"zoom: 33%\;\" \/><\/p><h4 id=\'差异表达基因kegg富集列表\'><span>差异表达基因<\/span><a
    href=\'$name\\$name\_kegg_enrichment.xlsx\'><span>KEGG富集列表<\/span><\/a><\/h4><p><span>下图是差异表达基因富集富集到的全部kegg通路图(可点开左下方的web按钮\,红框红字的条目代表差异基因富集到通路的此条目上\,右上角是通路的名称和描述\,可以再次点开详细查看通路的功能描述\,相关的基因等信息)</span>";
    my @pathway_info=<$group/*html>;
    for my $pathway_info (@pathway_info){
        my ($pathway)=basename $pathway_info=~/(\S+?).html/;
        print O "<\/p><p><span>富集通路-$pathway<\/span><\/p><p><img src=\"$name\\$pathway.$name.png\" alt=\"$pathway.$name\" style=\"zoom: 80%\;\" \/><\/p><p><a href=\'https:\/\/www.kegg.jp\/kegg-bin\/show_pathway?$pathway\/$f{$pathway}\'><span>web<\/span><\/a>";
    } 
    print O "<\/p><p>&nbsp\;<\/div><\/div>\n<\/body>\n<\/html>"; 
}

#https://www.kegg.jp/kegg-bin/show_pathway?aalt00010/CC77DRAFT_969684/CC77DRAFT_943642/CC77DRAFT_1004828/CC77DRAFT_936871/CC77DRAFT_844199/CC77DRAFT_1034248/CC77DRAFT_1028303/CC77DRAFT_1019268/CC77DRAFT_1056166
=c
</style><title>差异表达基因富集分析</title>
</head>
<body class='typora-export os-windows'><div class='typora-export-content'>
<div id='write'  class=''><h3 id='差异表达基因富集分析'><span>差异表达基因富集分析</span></h3><p><span>差异表达
基因GO</span><a href='C_VS_A\C_VS_A_go_enrichment.xlsx'><span>富集列表</span></a></p><p><span>富集GO</span></p><p><img src="C:\Users\wangm\Desktop\DEG_enrichment\C_VS_A\C_VS_A_go_enrichment_barplot.png" alt="C_VS_A_go_enrichment_barplot" style="zoom: 25%;" /></p><p><span>Dotplot</span></p><p><img src="C:\Users\wangm\Desktop\DEG_enrichment\C_VS_A\C_VS_A_go_enrichment_dotplot.png" alt="C_VS_A_go_enrichment_dotplot" style="zoom:25%;" /></p><p><span>cnetplot</span></p><p><img src="C:\Users\wangm\Desktop\DEG_enrichment\C_VS_A\C_VS_A_go_enrichment_emapplot.png" style="zoom: 33%;" /></p><p><span>差异表达基因kegg</span><a href='C_VS_A\C_VS_A_kegg_enrichment.xlsx'><span>富集列表</span></a></p><p><span>富集通路</span></p><p><img src="C:\Users\wangm\Desktop\DEG_enrichment\C_VS_A\cic00196.C_VS_A.png" alt="cic00196.C_VS_A" style="zoom: 80%;" /></p><p><a href='https://www.genome.jp/pathway/cic00196'><span>web</span></a></p><p>&nbsp;</p></div></div>
</body>
</html>
