#!/usr/bin/perl -w

use strict;
use lib '/home/andy/release/src/scripts';
use Sys::Hostname;
use Getopt::Long;
use Utils::lib::Utils;

# Home directory backup using rsync
#  02-28-09 Add home directories on sv1:/export/home
#  05-12-09 sync to home directories on sv2:/export/pub
###################################################################

sub backupdir();
sub Options;
sub gettime;
sub execsys;
sub diffTime;
sub calcElapsedTime;


###################################################################
# Constants
#
###################################################################

my ($curdate,$tmp,$debug,$mounted,$hostname,$device,$diskonly,@callret,$time,$retvalue,$command,@message,$sourcedir,$destdir,$weekly,$startTime,$endTime,$elapsedTime,$LOG,$logfile,$saturday);

$weekly = '';
$diskonly = '';

# Set to 0 for normal operation
$debug = 0;

Options(\$diskonly,\$weekly);

$hostname = hostname();
if(!grep(/sv5/,$hostname)) {
  print "This is not host sv1.\nExiting\n";
  exit(1);
}

undef $tmp;
($tmp) = (localtime)[6];

# 'Prevent weekly backup for now to save disk
if ($tmp eq '6') {$saturday = 1;}

# Set Saturday backup to zero to prevent backup.
$saturday = 0;

$curdate = `date`;
chomp($curdate);

open(FH ,">/tmp/email1.txt") || die "Can't open file";
print FH "\nBackup started on $curdate.\n";

# Backup Unix home directories on sv5
  $time = gettime();
  $startTime = time();
  print FH  "\nBackup of sv5:/export/home1 started at $time.\n";
  $command = "rsync -a --delete --exclude='*.trn' /export/home1 store:/bk2/sv5";
  print $command;
  if(Utils::execSys($command,\@message)) {
    print FH  "rsync of sv5:/export/home1 returned non zero.\n";
    print FH @message;
  }
  $elapsedTime = diffTime($startTime);
  print FH "Backup of sv5:/export/home1 Complete: Elapsed time $elapsedTime\n"; 

# Backup Unix home directories on sv5 /export/home2
  $time = gettime();
  $startTime = time();
  print FH  "\n\nBackup of sv5:/export/home2 started at $time.\n";
  $command = "rsync -a --delete --exclude='*.trn' /export/home2 store:/bk2/sv5";
  print $command;
  if(Utils::execSys($command,\@message)) {
    print FH  "rsync of sv5:/export/home2 returned non zero.\n";
    print FH @message;
  }
  $elapsedTime = diffTime($startTime);
  print FH "Backup of sv5:/export/home2 Complete: Elapsed time $elapsedTime\n"; 


# home3 pd has moved to other backup
#  $time = gettime(); 
#  $startTime = time();  
#  print FH  "\n\nBackup of sv5:/export/home3 started at $time.\n";
#  $command = "rsync -a --delete --exclude='*.trn' /export/home3 store:/bk2/sv5";
#  print $command;
#  if(Utils::execSys($command,\@message)) {
#    print FH  "rsync of sv5:/export/home3 returned non zero.\n";
#    print FH @message;
#  }
#  $elapsedTime = diffTime($startTime);
#  print FH "Backup of sv5:/export/home3 Complete: Elapsed time $elapsedTime\n"; 


# home4
  $time = gettime(); 
  $startTime = time();  
  print FH  "\n\nBackup of sv5:/export/home4 started at $time.\n";
  $command = "rsync -a --delete --exclude='*.trn' /export/home4 store:/bk2/sv5";
  print $command;
  if(Utils::execSys($command,\@message)) {
    print FH  "rsync of sv5:/export/home4 returned non zero.\n";
    print FH @message;
  }
  $elapsedTime = diffTime($startTime);
  print FH "Backup of sv5:/export/home4 Complete: Elapsed time $elapsedTime\n"; 


$curdate = `date`;
chomp($curdate);
print FH "\n\nBackup completed on $curdate.\n";
close(FH);

# Send notification
system 'mail -s "Rsync backup sv5 /home completed" andy@r2semi.com  < /tmp/email1.txt';

exit;



# Backup of Windows public directory 
  $time = gettime();
  $startTime = time();
  print "\nBackup of fs02:/public at $time.\n";
  print FH "\nBackup of fs02:/public at $time.\n";
#  $command = 'rsync -a --delete /public dev1:/export/pubbackup';
#  if($retvalue = execsys($command)) {
#    print "rsync call to backup fs02:/public failed with status $retvalue.\n";
#  }
  $endTime = time();
  if(calcElapsedTime($startTime,$endTime,\$elapsedTime)) {
    print "Call to elapsed time failed in fs02:/public.\n";
  }
  print FH "Backup of fs02:/public complete: Elapsed time: $elapsedTime\n";
  print $LOG "Backup of fs02:/public complete: Elapsed time: $elapsedTime\n";
  print "Backup of fs02:/public complete. Elapsed time: $elapsedTime\n";


# Windows
if($debug == 0) {
  system "rsync -a --delete /public backup:/export/bk2 >> /tmp/email.txt";
}

$curdate = `date`;
chomp($curdate);

open(FH ,">>/tmp/email.txt") || die "Can't open file log file.";
print FH "\nUnix backup completed on $curdate.\n";
close(FH);
close($LOG);

# Send notification
system 'mail -s "Rsync backup completed" andy < /tmp/email.txt';

#######################################################################
sub Usage()

{
  my ($string);

  $string = "Backup all important data. 
             nbackup.pl [-diskonly]
             -diskonly  Skip USB disk backup. 
             -weekly  Weekly backup. 
           ";
  print "$string\n";
  exit(0);
}


sub Options()

{
  my($ok,$unix,$help,$weekly);

  ($unix,$weekly) = @_;


  $help = '';
  $weekly = '';

  $ok = GetOptions('help' => \$help,
                   'diskonly' => $unix,
                   'weekly' => $weekly 
                  );

  if(!$ok || $help) { 
  Usage();
  }
}

############################################################
# sub gettime
#
# Return the current time

sub gettime()

{
my ($hour,$minutes,$seconds,$currenttime);

($seconds,$minutes,$hour) = localtime();

if($seconds < 10) { $seconds = '0' . $seconds; }
if($minutes < 10) { $minutes = '0' . $minutes; }
if($hour < 10) { $hour = '0' . $hour; }

$currenttime = "Current Time: " . $hour . ":" . $minutes . ":" . $seconds;
chomp($currenttime);
return($currenttime);
}
 

############################################################
#
# execsys: Execute a system call and return status.
#
# Input:    String: Command to execute. 
#   
# Returns:  Return 0 if success. System call actual return value if error. 
#           
############################################################

sub execsys()

{

  my($command,$errors,$retvalue,$fret);

  ($command) = @_;

  if($retvalue = system $command) {
    return($? >> 8);
    }
    else {
      return(0);
   } 
 }


############################################################
#
# backupdir: Copy in archive mode from source to destination directory.
#
# Input:    Complete ssh command   
#   
# Returns:  Returns 0 if successful.   
#           Reference to array with messages. 
#
############################################################

sub backupdir()

{
my ($rsynccommand,$message);

($rsynccommand,@$message) = @_; 

print "In backup subrouting.  $rsynccommand";
print "Exiting Sub\n";

}

############################################################
#
# elaspsedTime: Elaspsed Time between two times.
#
# Input:    String start time in seconds since epoch. End time.   
#            Reference to string for results. 
#   
# Returns:  Return 0 if success or 1 if failure.  
#           Elasped time in format MIN:SEC in $reference to string.  
#                   
#
############################################################

sub calcElapsedTime()

{

  my($startTime,$endTime,$elapsedTime,$results,$minutes,$seconds);

  ($startTime,$endTime,$results) = @_;

  $elapsedTime = $endTime - $startTime;
  if($elapsedTime < 0) {
    $$results = "Error: ElapsedTime is negative.\n";
    return(1);
    }  else {
    $minutes = $elapsedTime / 60;
    $seconds = $elapsedTime % 60;
    $$results = sprintf("%02d:%02d",$minutes,$seconds);
  }
  return(0);
} 


############################################################
#
# diffTime: Elaspsed Time between time passed and current time.
#
# Input:    Beginning time in seconds since epoch.    
#   
# Returns:  Returns string. Difference in time.   
#           Elasped time in format MIN:SEC in $reference to string.  
#                   
#
############################################################

sub diffTime()

{

  my($startTime,$endTime,$elapsedTime,$results,$minutes,$seconds);

  ($startTime) = @_;

  $endTime = time();
  $elapsedTime = $endTime - $startTime;
  $minutes = $elapsedTime / 60;
  $seconds = $elapsedTime % 60;
  $results = sprintf("%02d:%02d",$minutes,$seconds);
  
  return($results);
} 


