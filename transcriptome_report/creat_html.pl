use strict;
use File::Basename qw(dirname basename);
use FindBin qw($Bin $Script);

my $config="transcriptome_report.config";
open IN,"$config";
my %conf;
while(<IN>){
    chomp;
    next if /^#|^$/;
    my @info=split/\s+/,$_;
    $conf{$info[0]}=$info[1];
}
close IN;
`mkdir $conf{title}` unless (-e $conf{title});
`mkdir "$conf{title}/Basic_stats"` unless (-e "$conf{title}/Basic_stats");
`mkdir "$conf{title}/DEG_analyse"` unless (-e "$conf{title}/DEG_analyse");
`mkdir "$conf{title}/DEG_enrichment"` unless (-e "$conf{title}/DEG_enrichment");

`cp -r $Bin/template $conf{title}/`;
`cp -r $conf{workdir}/*/*xlsx $conf{title}/Basic_stats`;
`cp -r $conf{workdir}/05.differential_expression_gene/* $conf{title}/DEG_analyse`;
`cp -r $conf{workdir}/DEG_enrichment/* $conf{title}/DEG_enrichment`;


open O,">$conf{title}/$conf{title}.html";
open I,"$Bin/transcriptome.template";
while(<I>){
    print O "$_";
}
close I;

print O "<\/style><title>$conf{title}<\/title>\n";
print O "<\/head>\n";
print O "<body class=\'typora-export os-windows\'><div class=\'typora-export-content\'>\n";

print O "<div id=\'write\'  class=\'\'><h1 id=\'$conf{title}\'><span>$conf{title}<\/span><\/h1><h2 id=\'摘要\'><span>摘要<\/span><\/h2><p><span>分析结果概述<\/span><\/p><p><span>完成$conf{samples}个样品的有参转录组分析. 原始数据质控后得到Clean Reads\, 再分别将各样品的Clean  Reads与指定的参考基因组进行序列比对. 基于比对结果\, 进行基因表达量分析.  根据基因在不同样品中的表达量筛选差异表达基因\, 并对其进行功能注释和富集分析. <\/span><\/p><p>&nbsp\;<\/p><h2 id=\'测序数据及其质量控制\'><span>测序数据及其质量控制<\/span><\/h2><p><a href=\'https:\/\/github.com\/OpenGene\/fastp\'><span>fastp<\/span><\/a><span>是\”一步到位\“并且快速的原始数据质控工具<\/span><\/p><p><span>(1) 去除含有接头的Reads\; </span><\/p><p><span>(2) 去除低质量\, 长度过短\, 含有过多N的reads\; <\/span><\/p><p><span>(3) 滑窗统计每条reads的3\‘端和5\’端的平均质量值并去除低质量的碱基\; <\/span><\/p><p><span>(4) 修正双端reads重叠区域存在错配的碱基. <\/span><\/p><h5 id=\'质控数据统计\'><a href=\'Basic_stats\\reads_stat.xlsx\'><span>质控数据统计<\/span><\/a><\/h5><p>&nbsp\;<\/p><h2 id=\'转录组数据与参考基因组序列比对\'><span>转录组数据与参考基因组序列比对<\/span><\/h2><p><span>本项目使用指定的基因组作为参考进行序列比对及后续分析. 参考基因组下载地址见: <\/span><a href=\'$conf{ref_genome}\' target=\'_blank\' class=\'url\'>$conf{ref_genome}<\/a><span>. <\/span><\/p><p><a href=\'http:\/\/daehwankimlab.github.io\/hisat2\/\'><span>HISAT2<\/span><\/a><span>是高效并且灵敏的第二代短读长RNA测序数据比对工具\, 它使用了基于Burrows-Wheeler变换和Graph Ferragina-Manzini (GFM) index 两种算法的索引框架\, 利用了两类索引进行比对：一类是全基因组范围的FM索引来锚定每一个比对\, 另一类是大量的局部索引对这些比对做快速的扩展\, 实现了更快的速度和更少的资源占用\, 这种新的索引方案被称为 Hierarchical Graph FM index (HGFM). <\/span><\/p><p><a href=\'http:\/\/ccb.jhu.edu\/software\/stringtie\/index.shtml\'><span>StringTie<\/span><\/a><span>是快速并且高效的RNA-Seq转录本组装和定量工具\, 其采用了新的网络流算法和一种可供选择的从头组装步骤\,即利用比对信息构建多可变剪切图谱运用构建流量网络从而根据最大流量算法来进行组装和评估表达量. <\/span><\/p><p><span>比对分析完成后利用StringTie对比对上的Reads进行组装和定量. 分析流程如下图: <\/span><img src=\"template\\DE_pipeline.png\" referrerpolicy=\"no-referrer\" alt=\"DE_pipeline\"><\/p><h3 id=\'比对效率统计\'><span>比对效率统计<\/span><\/h3><p><span>比对效率指Mapped Reads占Clean Reads的百分比\, 是
转录组数据利用率的最直接体现. 比对效率除了受数据测序质量影响外\, 还与指定的参考基因组组装的优劣\,  参考基因组与测序样品的生物学分类关系远近(亚种)有关. 通过比对效率\, 可以评估所选参考基因组组装是否能满足信息分析的需求\, 也可以评估测序数据的质量. <\/span><\/p><p><a href=\'Basic_stats\\sample_mapping_rate.xlsx\'><span>比对效率统计<\/span><\/a><\/p><p>&nbsp\;<\/p><h2 id=\'基因表达量分析\'><span>基因表达量分析<\/span><\/h2><p><span>Reads比对到参考基因组上之后\, 接下来就是
要计算每个基因或转录本比对到的reads数目的多少\, 一个基因表达水平的直接体现就是其转录本的丰度情况\, 转录本丰度越高\, 则基因表达水平越高\, 此外转录本的reads比对数目与测序数据量\, 转录本长度(或基因长度)\, 转录本组成(RNA composition)\, 为了让reads比对数目能真实地反映转录本表达水平\, 需要对样品中比对上的reads的数目和转录本长度(基因长度)进行归一化. <\/span><\/p><p><a href=\'Basic_stats\\gene_count_matrix.xlsx\'><span>原始表达量<\/span><\/a><\/p><p><a href=\'Basic_stats\\gene_normalized_count_matrix.xlsx\'><span>标准化表达量<\/span><\/a><\/p><h2 id=\'差异表达基因分析\'><span>差异表达基因分析<\/span><\/h2><p><span>在不同背景下比较基因转录本的表达水平<\/span><\/p><ul><li><span>同一物种\, 不同组织: 研究基因在不同部分的表达情况\; <\/span><\/li><li><span>同一物种\, 同一组织: 研究基因在不同处理下\, 不同条件下的表达变化\; <\/span><\/li><li><span>同一组织\, 不同物种: 研究基因的进化关系\; <\/span><\/li><li><span>时间序列实验: 基因在不同时期的表达情况与发育的关系\; </span></li></ul><p><span>基因分类: 找到细胞特异\, 疾病相关\, 抗性相关\, 处理相关等的基因表达模式\; <\/span><\/p><p><span>基因网络和通路: 基因在细胞活动中的功能\, 基因间的相互作用\, 基因参与的生化反应和调节通路\; <\/span><\/p><p><span>通过研究基因的差异表达\, 我们可以发现: 细胞特异性的基因\, 发育阶段特异性的基因\, 疾病状态相关的基因\,环境相关的基因等. <\/span><\/p><h3 id=\'差异表达基因筛选\'><span>差异表达基因筛选<\/span><\/h3><p><span>基本方法就是以<\/span><strong><span>生物学意义<\/span><\/strong><span>的方式计算基因表达量\,      然后通过统计学分析表达量寻找具有统计学显著性差异的基因\, 从而<\/span><\/p><ul><li><span>选择合适的基因集<\/span><\/li><li><span>衡量结果的可靠性</span><\/li><\/ul>";

for my $html (<$conf{title}/DEG_analyse/*html>){
    $html=basename $html;
    my ($name)=$html=~/(\S+)\_DE_analyse.html/;
    print O "<p><a href=\'DEG_analyse\\$html\'><span>$name差异表达基因分析结果<\/span><\/a><\/p>";
}

print O "<h3 id=\'差异表达基因富集\'><span>差异表达基因富集<\/span><\/h3><p><span>对差异表达基因集进行GO和KEGG富集分析<\/span><\/p>";

for my $html (<$conf{title}/DEG_enrichment/*html>){
    $html=basename $html;
    my ($name)=$html=~/(\S+)\_DE_enrichment.html/;
    print O "<p><a href=\'DEG_enrichment\\$html\'><span>$name差异表达基因富集结果<\/span><\/a><\/p>";
}

print O "<p>&nbsp\;<\/p>";

print O "<h2 id=\'软件名称\'><span>软件名称<\/span><\/h2><blockquote><figure><table><thea
d><tr><th><span>software<\/span><\/th><th><span>version<\/span><\/th><th><span>identifer<\/span><\/th><\/tr><\/thead><tbody><tr><td>&nbsp\;<\/td><td>&nbsp\;<\/td><td>&nbsp\;<\/td><\/tr><tr><td><span>fastp<\/span><\/td><td><span>0.21.0<\/span><\/td><td><a href=\'https:\/\/github.com\/OpenGene\/fastp\' target=\'_blank\' class=\'url\'>https:\/\/github.com\/OpenGene\/fastp<\/a><\/td><\/tr><tr><td>&nbsp\;<\/td><td>&nbsp\;<\/td><td>&nbsp\;<\/td><\/tr><tr><td><span>hisat<\/span><\/td><td><span>2.2.1<\/span><\/td><td><a href=\'https:\/\/github.com\/DaehwanKimLab\/hisat2\' target=\'_blank\' class=\'url\'>https:\/\/github.com\/DaehwanKimLab\/hisat2<\/a><\/td><\/tr><tr><td>&nbsp\;<\/td><td>&nbsp\;<\/td><td>&nbsp\;<\/td><\/tr><tr><td><span>samtools<\/span><\/td><td><span>1.12<\/span><\/td><td><a href=\'https:\/\/github.com\/samtools\/samtools\' target=\'_blank\' class=\'url\'>https:\/\/github.com\/samtools\/samtools<\/a><\/td><\/tr><tr><td>&nbsp\;<\/td><td>&nbsp\;<\/td><td>&nbsp\;<\/td><\/tr><tr><td><span>stringtie<\/span><\/td><td><span>2.1.5<\/span><\/td><td><a href=\'https:\/\/github.com\/gpertea\/stringtie\' target=\'_blank\' class=\'url\'>https:\/\/github.com\/gpertea\/stringtie<\/a><\/td><\/tr><tr><td>&nbsp\;<\/td><td>&nbsp\;<\/td><td>&nbsp\;<\/td><\/tr><tr><td><span>DESeq2<\/span><\/td><td><span>2.30.1<\/span><\/td><td><a href=\'https:\/\/bioconductor.org\/packages\/release\/bioc\/html\/DESeq2.html\' target=\'_blank\' class=\'url\'>https:\/\/bioconductor.org\/packages\/release\/bioc\/html\/DESeq2.html<\/a><\/td><\/tr><tr><td>&nbsp\;<\/td><td>&nbsp\;<\/td><td>&nbsp\;<\/td><\/tr><tr><td><span>clusterProfiler<\/span><\/td><td><span>3.18.1<\/span><\/td><td><a href=\'https:\/\/github.com\/YuLab-SMU\/clusterProfiler\' target=\'_blank\' class=\'url\'>https:\/\/github.com\/YuLab-SMU\/clusterProfiler<\/a><\/td><\/tr><tr><td>&nbsp\;<\/td><td>&nbsp\;<\/td><td>&nbsp\;<\/td><\/tr><tr><td><span>pathview<\/span><\/td><td><span>1.32.0<\/span><\/td><td><a href=\'https:\/\/github.com\/datapplab\/pathview\' target=\'_blank\' class=\'url\'>https:\/\/github.com\/datapplab\/pathview<\/a><\/td><\/tr><tr><td>&nbsp\;<\/td><td>&nbsp\;<\/td><td>&nbsp\;<\/td><\/tr><tr><td><span>pheatmap<\/span><\/td><td><span>1.0.12<\/span><\/td><td><a href=\'https:\/\/github.com\/raivokolde\/pheatmap\' target=\'_blank\' class=\'url\'>https:\/\/github.com\/raivokolde\/pheatmap<\/a><\/td><\/tr><\/tbody><\/table><\/figure><\/blockquote><p>&nbsp\;<\/p><p>&nbsp\;<\/p>";

print O "<h2 id=\'参考文献\'><span>参考文献<\/span><\/h2><p><span>Chen S\, Zhou Y\, Chen Y\, et al. fastp: an ultra-fast all-in-one FASTQ preprocessor[J]. Bioinformatics\, 2018\, 34(17): i884-i890. <\/span><\/p><p><span>Kim D\, Paggi J M\, Park C\, et al.  Graph-based genome alignment and genotyping with HISAT2 and  HISAT-genotype[J]. Nature biotechnology, 2019, 37(8): 907-915.<\/span><\/p><p><span>Kovaka S, Zimin A V\, Pertea G M\, et  al. Transcriptome assembly from long-read RNA-seq alignments with  StringTie2[J]. Genome biology\, 2019\, 20(1): 1-13.<\/span><\/p><p><span>Love M I\, Huber W\, Anders S. Moderated estimation of fold change and dispersion for RNA-seq data with  DESeq2[J]. Genome biology\, 2014\, 15(12): 1-21.  <\/span><\/p><p><span>Li H\, Handsaker B\, Wysoker A\, et al. The sequence alignment/map format and SAMtools[J]. Bioinformatics\, 2009\, 25(16): 2078-2079.<\/span><\/p><p><span>Yu G\, Wang L\, Han Y and He Q\*. clusterProfiler: an R package for comparing biological themes among gene clusters. OMICS: A Journal of Integrative Biology. 2012\, 16(5):284-287.<\/span><\/p><p><span>Luo W\, Brouwer C. Pathview: an R/Biocondutor package for pathway-based data integration and visualization. Bioinformatics\, 2013\, 29(14):1830-1831\, doi: 10.1093\/bioinformatics\/btt285<\/span><\/p><\/div><\/div>";

print O "<\/body>\n<\/html>";
