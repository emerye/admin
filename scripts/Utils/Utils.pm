package Utils;

use 5.001005;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Utils ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(logFile execSys
	
);

our $VERSION = '0.01';
##################################################################
# logName()
# 
# Return a logfile name based on the current date and time. 
#   
# Input: None 
# Output: None
# Returns: String based on date and time to be used for log file. 
#
##################################################################

sub logName()
  { 
  my ($sec,$min,$hour,$dayOfMonth,$month,$year,$date,$time,$logDateTime);

  ($sec,$min,$hour,$dayOfMonth,$month,$year)= (localtime)[0,1,2,3,4,5,6]; 
  $year += 1900;
  $month += 1;
  $date = sprintf("%04d%02d%02d",$year,$month,$dayOfMonth);
  $time = sprintf("%02d%02d",$hour,$min);
  $logDateTime = $date . "T" . $time;
  chomp($logDateTime);
  return($logDateTime);
  }


##################################################################
# execSys($command,\@commandreturn);
# 
# Execute a system command. Results are returned in reference to array. 
#   
# Input: command to execute, array reference. 
# Output: Full results in reference to array.  
# Returns: 0 if successful. Command results place in array.  
#
##################################################################

sub execSys($@$) 

  {
  my ($errorptr,$command,$pid,@output,$exitstat);

  ($command,$errorptr) = @_;
  
  undef($pid);
  $pid = open(FH, "$command 2>&1 |"); 
  if(! defined($pid)) {
    push @$errorptr, "Error: Could not open pipe to command.\n";
    return(1);
  }  
  @output = <FH>; 
  push @$errorptr,@output;
  $exitstat = close FH;
  if(!$exitstat) {
    push @$errorptr, "Error: execSys $command Returned $?\n";
    return(1);
  }
  return(0);
}



# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Utils - Perl extension for Liga Utilities 

=head1 SYNOPSIS

use Utils;
Liga Perl Utilities 

=head1 DESCRIPTION

General Perl Utilities 
logName() Input none. Returns a log name based on the date and time. 
execSys($command,\@ref) Execute a system command. Results returned in array.
Return 0 if successful.


=head2 EXPORT


None by default.


=head1 SEE ALSO



=head1 AUTHOR

Andy Hughes, E<lt>andy@ligasystems.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Andy Hughes

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.


=cut
