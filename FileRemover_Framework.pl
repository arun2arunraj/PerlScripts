#!/usr/bin/perl -w
##################################################
#This script is responsible for making a secure  #
#connection via ssh to server1 and executing the #
#commaned ls .                                   #
#This script is also responsible for making a    #
#a secure connection via ssh to server1 and then #
#scp the file test.txt.                          #
##################################################

#import required modules
use strict;
use warnings;
use Term::ANSIColor;
use Net::SCP qw(scp iscp);
use Net::SSH qw(ssh);
use Log::Dispatch::Syslog;

#declare local variables
my $scp;
my $SharedRootPath;
my $SharedRelativePath;
my @hostnames = `cat /etc/solartis-config/serverlist`;

sub usage()
{

print colored(['bright_red on_black'], '######################################################',"\n");
print ( "       Solartis Shared Request-Response Generater       \n");
print ( "######################################################\n");
print ("It is used to collect Request Response from \n");
print ("Remote Server based on the Framework\n");
print ("Following is the \n");
print ("\nOPTIONS:\n");
print ("-------\n");
print ("        -F      Specify Framework\n");
print ("        -R      Specify Root Path\n");
print ("        -E      Specify Environment ( Not Enabled !!! )\n");


print("\n####################################\n");
}
&usage();

foreach my $i (@hostnames)
{
	chomp($i);
	print "$i\n";
}
my $host = "192.168.5.244";
my $user = "root";
my $remotedir = "/ActivityRepo/My_Script_Work/";
my $file = "/ActivityRepo/My_Script_Work/scp_copy.txt";
my $cmd = "/bin/ls";

#################### Log::Dispatch::Syslog #######################################
# Define our pid for use in the log message
my $pid = getppid();
# Define our logfile object
my $logfile = Log::Dispatch::Syslog->new( name => 'logfile',
                                          min_level => 'info',
                                          ident => "Solartis_SharedReqRes_Generator_ID[$pid]" );
#################### Log::Dispatch::Syslog #######################################

###### first connect to $host via Net::SSH and run /bin/ls ###########
$logfile->log( level => 'info', message => "Connecting to $host as $user and running /bin/ls ..." );
#ssh("$user\@$host", $cmd);
#$logfile->log( level => 'info', message => "ls completed successfully!" );
###### first connect to $host via Net::SSH and copy file $file ###########

#initialize Net::SCP object and send credentials
$scp = Net::SCP->new($host);

#notify user we're logging into $host
print "Logging into $host ...\n";

#write "connected to $host" to $file
$logfile->log( level => 'info', message => "Connected to $host successfully." );

#log into $host as $user
$scp->login($user) or die $scp->{errstr};

#write "connected to $host" to $file
$logfile->log( level => 'info', message => "Logged into $host successfully." );

#notify user of changing working directory to $remotedir
print "Chaging working directory to $remotedir\n";

#change working directory to $remotedir
$scp->cwd($remotedir) or die $scp->{errstr};

#Write Changed working directory (CWD) to $remotedir
$logfile->log( level => 'info', message => "CWD to $remotedir successfully." );

#display file size of $file
print "FILE $file ...\n";
#$scp->size($file) or die $scp->{errstr};

#notify user scp of $file has started
print "SCPing $file from $host ...\n";

#scp $file from $host
$scp->get($file) or die $scp->{errstr};

#notify user scp of $file from $host was successful
print "$remotedir$file copied from $host successfully!\n";
