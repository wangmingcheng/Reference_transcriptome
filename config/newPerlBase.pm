package newPerlBase;
use Exporter;
use strict;
use File::Basename qw(basename dirname);
use Cwd qw(abs_path);
use File::Path qw(make_path);
use FindBin qw($Bin $Script);
BEGIN {
        our @ISA = qw(Exporter);
        our @EXPORT = qw(selectconf readconf logAndDie runOrDie qsubOrDie forkOrDie qsubCheck createLog timeLog writeLog totalTime stepTime mkdirOrDie stepStart);
        our $VERSION = 2.0;
}

our $userlog;
our $syslog;
our $BEGIN_TIME=time();
my $nodename=`hostname`;chomp $nodename;
my $syslogpath="/data01/Biosoft/newPerlbase/v1.0.9/log";
my $signFile=`cat /data01/Biosoft/newPerlbase/v1.0.8/cluster`;chomp $signFile;
our %stepstarttime;
our %stepname;
sub createLog{   # createLog($name,$version,$pid,$path,$debug)
	my $name=shift;
	my $version=shift;
	my $pid=shift;
	my $userpath=shift;
	my $debug=shift;
	my $user=`whoami`;chomp $user;
	mkdirOrDie($userpath) if(!-d $userpath);
	$userpath=abs_path($userpath);
	my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst)=localtime($BEGIN_TIME);
	my $date=sprintf("%4d%02d%02d", $year+1900, $mon+1, $day);
	my $prefix=join("-",$name,$version,$date,$user,$pid,$BEGIN_TIME,$nodename);    #log file name prefix
	$prefix.="-debug" if(defined $debug);
	$syslog ="$syslogpath/$prefix.log" if(!defined $debug);
	$userlog="$userpath/$prefix.log";
	system("touch $syslog") if(!defined $debug);
	system("touch $userlog");
	my $workDir = `pwd`;chomp $workDir;
	my $cmdlog=`ps -p $pid -ocmd --no-header`;chomp $cmdlog;
	my $info="=======================================================\n"."start time:\t".($year+1900)."-".($mon+1)."-$day $hour:$min:$sec\n"."user:\t\t$user\n"."cmd:\t\t$cmdlog\n"."work directory:\t$workDir\n"."=======================================================\n";
	writeLog($info);
}
sub selectconf{# config should be named as "hpcXX.cfg", eg. hpc02.cfg ,for "cloud.cfg" for BMKcloud
    my $conf=shift; #input config dir
    $conf.="/$signFile.cfg";
    my $cfg=readconf($conf);
    return $cfg;
}
sub readconf{
	my $file=shift;
	my %cfg;
	open IN,$file or logAndDie("$file not exists!");
	while (<IN>) {
		chomp;
		next if($_=~/^#/);
		next if($_=~/^\s*$/);
		$_=~s/\r//g;
		$_=~s/^\s+//g;
		$_=~s/\s+$//g;
		my ($key,$value)=split /\s+/,$_,2;
		$cfg{$key}=$value;
	}
	close IN;
	return \%cfg;
}
sub qsubOrDie { # qsubOrDie($shell,$queue,$cpu,$vf)
	my ($shell,$queue,$cpu,$vf) = @_;
	# checking shfile
	if(!defined $shell){
		logAndDie("qsubOrDie: shell file is undefined");
	}
    $shell = abs_path($shell);
    system "sh $shell $queue $cpu $vf";
    #system "sh $shell";

}
sub qsubCheck {#
	# Check The qsub process if error happend 
	my $sh=shift;
	my @Check_file=glob "$sh*.qsub/*.Check";
	my @sh_file=glob "$sh*.qsub/*.sh";

	if ($#sh_file!=$#Check_file) {
		&logAndDie("Their Some Error Happend in $sh qsub, Please Check..");
	}else {
		&timeLog("qsub for $sh is Done!\n");
	}
}
sub forkOrDie { #forkOrDie($shell,$one_time_task_number)
        my ($shell,$one_time_task_number) = @_;
	# checking shfile
	if(!defined $shell){
		logAndDie("forkOrDie: shell file is undefined");
	}

        $shell=abs_path($shell);
	&timeLog($shell);
        my $begintime=time();
        open(SH,$shell);
        my @cmds=<SH>;
        close(SH);
        
	my $forks = 0;
        my $cmd;
        foreach $cmd (@cmds) {
                my $pid = fork;
                if (not defined $pid) {
                        warn 'Could not fork';
                        next;
                }
                if ($pid) {
                        $forks++;
                } else {
                        system "$cmd";
                        exit;
                }
                if ($forks == $one_time_task_number) {
                        for (1 .. $forks) {
                                my $pid = wait();
                        }
                $forks = 0;
                }
        }
	if ($forks != 0) {
		for (1 .. $forks) {
			my $pid = wait();
		}
	}
	infoTime($begintime,"command done!");
}
sub runOrDie
{
	my ($cmd) = @_ ;
	if($cmd!~/\s/){
		$cmd=abs_path($cmd);
		$cmd="sh $cmd"; # for shell file
	}
	&timeLog($cmd);
	my $begintime=time();
	my $flag = system($cmd);
	if ($flag != 0){
		&timeLog("Error: command fail: $cmd");
		exit(1);
	}
	infoTime($begintime,"command done!");
	return ;
}

sub totalTime {
	logAndDie("Start time not recorded!") if (!defined $BEGIN_TIME);
	infoTime($BEGIN_TIME,"All Analysis Finished!");
}
sub stepStart {
	my $num=shift;
	my $info=shift;
	$stepname{"step$num"}=$info;
	$stepstarttime{"step$num"}=time();
	my $detail="Step_$num: $info: start";
	timeLog($detail);
}
sub infoTime {
	my $starttime=shift;
	my $info=shift;
	my $els=time()-$starttime;
	my $detail="$info Elapsed time: $els s";
	timeLog($detail);
}
sub stepTime {
	my $num=shift;
	my $starttime;
	logAndDie("step_$num not started yet") if (!exists $stepname{"step$num"});
	my $info=$stepname{"step$num"};
	my $els=time()-$stepstarttime{"step$num"};
	my $detail="Step_$num: $info: finished! Elapsed time: $els s";
	timeLog($detail);
}
sub logAndDie {
	my $info = shift;
	my ($package, $filename, $line) = caller;
	# get file and line
	if(!defined $info){
		timeLog("logAndDie: info is undefined");
		die;
	}
	# log and die
	timeLog("FATAL ERROR (file $filename line $line): $info");
	die;
}
my $formatDateTime = sub{
	my($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = @_;
	my $format_time = sprintf("%4d-%02d-%02d %02d:%02d:%02d", 
		$year+1900, $mon+1, $day, $hour, $min, $sec);
	return $format_time;
};

sub timeLog {
	my $detail = shift;
	# get current time with string
	my $curr_time = &$formatDateTime(localtime(time()));
	# print info with time
	writeLog("[$curr_time] $detail");
}
sub writeLog{
	my $detail=shift;
	if(defined $userlog and defined $syslog){
		open OUT1,">>$userlog" or die("$userlog PATH ERROR!\n");
		open OUT2,">>$syslog" or die("$syslog PATH ERROR!\n");
		print OUT1 "$detail \n";
		print OUT2 "$detail \n";
		close OUT1;
		close OUT2;
	}elsif(defined $userlog and !defined $syslog){
		open OUT1,">>$userlog" or die("$userlog PATH ERROR!\n");
		print OUT1 "$detail \n";
		close OUT1;
	}else{
		print "$detail \n";
	}
}
sub mkdirOrDie
{
	my ($dir) = @_ ;
	if(!-d $dir){
		make_path($dir);
		$dir=abs_path($dir);
		timeLog("Directory Created: $dir");
	}
}
