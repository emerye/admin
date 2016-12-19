#!/usr/bin/perl

# Turn on warnings the best way depending on the Perl version. 
BEGIN { 
  if ( $] >= 5.006_000) 
    { require warnings; import warnings; } 
  else 
    { $^W = 1; } 
} 


use strict; 
use Carp; 



###################################################################### 
# Configuration section. 


# Svnlook path. 
my $svnlook = "/usr/bin/svnlook"; 
my $REPOPATH = "/data/svn/test";


# Since the path to svnlook depends upon the local installation 
# preferences, check that the required program exists to insure that 
# the administrator has set up the script properly. 
{ 
  my $ok = 1; 
  foreach my $program ($svnlook) 
    { 
      if (-e $program) 
        { 
          unless (-x $program) 
            { 
              warn "$0: required program `$program' is not executable, ", 
                   "edit $0.\n"; 
              $ok = 0; 
            } 
        } 
      else 
        { 
          warn "$0: required program `$program' does not exist, edit $0.\n"; 
          $ok = 0; 
        } 
    } 
  exit 1 unless $ok; 
} 


###################################################################### 
# Initial setup/command-line handling. 


&usage unless @ARGV == 2; 


my $repos = shift; 
my $txn = shift; 


unless (-e $repos) 
  { 
    &usage("$0: repository directory `$repos' does not exist."); 
  } 
unless (-d $repos) 
  { 
    &usage("$0: repository directory `$repos' is not a directory."); 
  } 


# Define two constant subroutines to stand for read-only or read-write 
# access to the repository. 
sub ACCESS_READ_ONLY () { 'read-only' } 
sub ACCESS_READ_WRITE () { 'read-write' } 



###################################################################### 
# Harvest data using svnlook. 


# Change into /tmp so that svnlook diff can create its .svnlook 
# directory. 
my $tmp_dir = '/tmp'; 
chdir($tmp_dir) 
  or die "$0: cannot chdir `$tmp_dir': $!\n"; 


# Figure out what files have added using svnlook. 
my @files_added; 
foreach my $line (&read_from_process($svnlook, 'changed', $repos, '-t', 
$txn)) 
  { 
        # Add only files that were added to @files_added 
    if ($line =~ /^A. (.*[^\/])$/) 
      { 
        push(@files_added, $1); 
      } 

 # Add changed files

    if ($line =~ /^U. (.*[^\/])$/) 
      { 
        push(@files_added, $1); 
      } 
  } 

my @errors; 
foreach my $path ( @files_added ) 
    { 
        my $needs_lock; 

        # Strip leading spaces in $path;
        $path =~ s/^\s+//g; 
        # Parse the complete list of property values of the file $path to extract. 
  
        my $filepath = '/' . "$path"; 
        
        # the needs-lock property 
        my $prop;

        foreach $prop (&read_from_process($svnlook, 'proplist', $repos,'-t',$txn, '--verbose', $filepath)) 
            { 
                if ($prop =~ /^\s*svn:needs-lock : (\S+)/) 
                    { 
                        $needs_lock = $1; 
                    } 
            } 

        # Detect error conditions and add them to @errors 
        if (not $needs_lock) 
            { 
                push @errors, "$path : svn:needs-lock is not set"; 
            } 
             
    } 


# If there are any errors list the problem files and give information 
# on how to avoid the problem. Hopefully people will set up auto-props 
# and will not see this verbose message more than once. 
if (@errors) 
  { 
    warn "$0:\n\n", 
         join("\n", @errors), "\n\n"; 

    push @errors, "Every added file must have the svn:needs-lock property set."; 
   
    push @errors, "Please add this to your client configuration and try again.";

    exit 1; 
  } 
else 
  { 
    exit 0; 
  } 


sub usage 
{ 
  warn "@_\n" if @_; 
  die "usage: $0 REPOS TXN-NAME\n"; 
} 


sub safe_read_from_pipe 
{ 
  unless (@_) 
    { 
      croak "$0: safe_read_from_pipe passed no arguments.\n"; 
    } 
  print "Running @_\n"; 
  my $pid = open(SAFE_READ, '-|'); 
  unless (defined $pid) 
    { 
      die "$0: cannot fork: $!\n"; 
    } 
  unless ($pid) 
    { 
      open(STDERR, ">&STDOUT") 
        or die "$0: cannot dup STDOUT: $!\n"; 
      exec(@_) 
        or die "$0: cannot exec `@_': $!\n"; 
    } 
  my @output; 
  while (<SAFE_READ>) 
    { 
      chomp; 
      push(@output, $_); 
    } 
  close(SAFE_READ); 
  my $result = $?; 
  my $exit = $result >> 8; 
  my $signal = $result & 127; 
  my $cd = $result & 128 ? "with core dump" : ""; 
  if ($signal or $cd) 
    { 
      warn "$0: pipe from `@_' failed $cd: exit=$exit signal=$signal\n"; 
    } 
  if (wantarray) 
    { 
      return ($result, @output); 
    } 
  else 
    { 
      return $result; 
    } 
} 


sub read_from_process 
  { 
  unless (@_) 
    { 
      croak "$0: read_from_process passed no arguments.\n"; 
    } 
  my ($status, @output) = &safe_read_from_pipe(@_); 
  if ($status) 
    { 
      if (@output) 
        { 
          die "$0: `@_' failed with this output:\n", join("\n", @output), 
"\n"; 
        } 
      else 
        { 
          die "$0: `@_' failed with no output.\n"; 
        } 
    } 
  else 
    { 
      return @output; 
    }
  }
