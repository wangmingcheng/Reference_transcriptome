use strict;
use File::Basename qw(dirname basename);
use FindBin qw($Bin $Script);

my @group=<./*>;
for my $group (@group){
    next unless (-d $group);
    my $name=basename $group;
    open O,">$name\_DE_analyse.html";
    open IN,"$Bin/template.html";
    while(<IN>){
        print O "$_";
    }
    close IN;
    print O "<\/style><title>$name-差异表达基因分析<\/title>\n";
    print O "<\/head>\n";
    print O "<body class=\'typora-export os-windows\'><div class=\'typora-export-content\'>\n";
    print O "<div id=\'write\'  class=\'\'><h2 id=\'差异表达基因基本分析\'><span>差异表达基因基本分析<\/span><\/h2><h3 id=\'差异表达基因筛选\'><span>差异表达基因筛选<\/span><\/h3><p><span>使用R软件包DESeq2分析得到所有基因的原始结果如下：<\/span><\/p><p><a href=\'$name\\$name.xlsx\'><span>原始列表<\/span><\/a><\/p><p><span>基于筛选标准(abs(log2FoldChange)&gt\;=1 and padj &lt\;=0.05)\,得到如下结果：<\/span><\/p><p><a href=\'$name\\$name\_DE.xlsx\'><span>差异表达基因列表<\/span><\/a><\/p><p><span>差异表达基因表达量标准化后的结果如下：<\/span><\/p><p><a href=\'$name\\$name\_DE.counts.xlsx\'><span>差异表达基因表达量<\/span><\/a><\/p><h3 id=\'差异表达基因基本分析结果可视化\'><span>差异表达基因基本分析结果可视化<\/span><\/h3><p><span>火山图<\/span><\/p><p><img src=\"$name\\$name\_volcano.png\" referrerpolicy=\"no-referrer\" alt=\"$name\_volcano\"><\/p><p><span>MA图(M-versus-A plot)<\/span><\/p><p><img src=\"$name\\$name\_MA.png\" referrerpolicy=\"no-referrer\" alt=\"$name\_MA\"><\/p><p><span>差异基因表达量热图<\/span><\/p><p><img src=\"$name\\$name\_DE_heatmap.png\" referrerpolicy=\"no-referrer\" alt=\"$name\_DE_heatmap\"><\/p><p><span>样本间相关性热图<\/span><\/p><p><img src=\"$name\\$name\_cor.png\" referrerpolicy=\"no-referrer\" alt=\"$name\_cor.png\"><\/p><p>&nbsp\;<\/p><p><span>样本聚类PCA<\/span><\/p><p><img src=\"$name\\$name\_PCA.png\" referrerpolicy=\"no-referrer\" alt=\"$name\_PCA\"><\/p><\/div><\/div>\n";
    print O "<\/body>\n<\/html>"; 
}
