#!/usr/bin/perl
use strict;
use warnings;
use Net::SMTP;  

my (@dfout, @fields, $pused, $curhost, $summary); 
my $dir = "/space";

my @disk = ([],[]);   

 
# This will return the amount of space use in a file system in percent.
# Parameters are host name, name of file system.  
sub diskusage($$)
{
my ($hostname, $fs) = @_;
my (@fields, @dfout, $free);

#print("Hostname $hostname filesystem $fs", "\n");
@dfout = `ssh andy\@$hostname df -Pk $fs`;

@fields = split(/\s+/,$dfout[1]);
$pused = $fields[4]; 
$pused =~ s/%//;
$free = 100 - $pused;
$summary = $summary .  "$fs partition on $hostname has $free percent free space.\n"; 
return($pused);
}

sub sendMessage()
{
my ($smtpObj, $to1, $to2, $iRetValue, $subject); 
$to1 = 'ahughes@r2semi.com';
$subject = 'Subject:Disk Usage';

if (! ($smtpObj = Net::SMTP->new("localhost")))
	{
	print("Failed to create smtp object.\n");
	exit(1);
}
	
$smtpObj->mail("ahughes\@r2semi.com");
$smtpObj->to("ahughes\@r2semi.com");
$smtpObj->recipient($to1);
$smtpObj->data();
$smtpObj->datasend($subject, "\n");
$smtpObj->datasend("\n");

$smtpObj->datasend("$summary", "\n");
$smtpObj->datasend(); 
$smtpObj->quit;

}


# Main
{

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst); 

($sec,$min,$hour,$mday,$mon,$year,$wday,
$yday,$isdst)=localtime(time);


$summary = "Current time:  "; 
$summary = $summary . sprintf("%4d-%02d-%02d %02d:%02d:%02d\n",$year+1900, $mon+1, $mday, $hour, $min, $sec);  

$summary = $summary . "\nSim Disk Usage\n"; 
diskusage("sv3", "/space"); 
diskusage("sv4", "/space"); 
diskusage("sv6", "/space"); 
diskusage("sv7", "/space");
diskusage("sv8", "/space");
diskusage("sv8", "/space1");
$summary = $summary . "\n\nFile Systems\n";
diskusage("sv1", "/export/home");
diskusage("sv5", "/export/home1");
diskusage("sv5", "/export/home2");
diskusage("sv5", "/export/home3");
diskusage("sv5", "/export/home4");
sendMessage(); 
}


