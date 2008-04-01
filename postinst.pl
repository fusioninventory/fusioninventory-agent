#!/usr/bin/perl -w

use strict;

use lib 'lib';

use XML::Simple;
use Ocsinventory::Agent::Config;

my $old_linux_agent_dir = "/etc/ocsinventory-client";

my $config;
my @cacert;

sub ask_yn {
    my $prompt = shift;

    print $prompt."?\n";

    while (1) {
        print "Please enter 'y' or 'n'>\n";
        chomp(my $line = <STDIN>);
        return 1 if $line =~ /^y$/;
        return if $line =~ /^n$/;
    }
}

sub prompt {
    my ($prompt, $default, $regex, $notice) = @_;

    print $prompt;
    print "($default)" if $default;
    print "?:\n";

    my $line;
    while (1) {

        print ">\n";
        chomp($line = <STDIN>);

        if ($line =~ /^$/ and $default) {
            print "[nfo] Using the default value ($default)\n";
            $line = $default;
            last;
        }

        last unless $regex && $line !~ /$regex/;
        
        print $notice."\n";

    }

    return $line;
}

sub pickConfigdir {
    my @choices = @_;

    foreach (@choices) {

        my $t = $_.'/ocsinventory-agent.cfg';

        if (-f $t) {
            print "Config file found are $t! Reusing it.\n";
            return $_; 
        }
    }

    print "Where do you want to write the configuration file?\n";
    foreach (0..$#choices) {
        print " ".$_." -> ".$choices[$_]."\n";
    }
    my $input = -1;
    my $configdir;
    while (!($input =~ /^\d+$/ && $input >= 0 && $input <= $#choices)) {
        print ">";
        chomp($input = <STDIN>);
    }


    if (! -d $choices[$input]) {
        if (ask_yn ("Do you want to create the directory ".$choices[$input]."?")) {
            if (!mkdir $choices[$input]) {
                print "Failed to create ".$choices[$input].". Are you root?\n";
                exit 1;
            }
        } else {
            print "Please create the ".$choices[$input]." directory first.\n";
            exit 1;
        }
    }

    return $choices[$input];
}

sub recMkdir {
  my $dir = shift;

  my @t = split /\//, $dir;
  shift @t;
  return unless @t;

  my $t;
  foreach (@t) {
    $t .= '/'.$_;
    if ((!-d $t) && (!mkdir $t)) {
      return;
    }
  }
  1;
}

####################################################
################### main ###########################
####################################################

if (!ask_yn("Do you want to configure the agent")) {
    exit 0;
}


my $configdir = pickConfigdir ("/etc/ocsinventory", "/usr/local/etc/ocsinventory", "/etc/ocsinventory-agent");

if (-f $old_linux_agent_dir.'/ocsinv.conf' && ask_yn("Should the old linux_agent settings be imported?")) {
    my $ocsinv = XMLin($old_linux_agent_dir.'/ocsinv.conf');
    my $server = '';
    $server .= 'http://' unless $ocsinv->{'OCSFSERVER'} =~ /^http(s|):\/\//;
    $server .= $ocsinv->{'OCSFSERVER'}.'/ocsinventory';
    $config->{server} = $server;

    if (-f $old_linux_agent_dir.'/cacert.pem') {
        open CACERT, $old_linux_agent_dir.'/cacert.pem' or die "Can'i import the CA certificat: ".$!;
        @cacert = <CACERT>;
        close CACERT;
    }

    my $admcontent = '';
    open(ADM, "<:encoding(iso-8859-1)", "$old_linux_agent_dir/ocsinv.adm")
        or die "Can't open $old_linux_agent_dir/ocsinv.adm";
    $admcontent .= $_ foreach (<ADM>);
    close ADM;
    my $admdata = XMLin($admcontent) or die;
    foreach (@{$admdata->{ACCOUNTINFO}}) {
        $config->{tag} = $_->{KEYVALUE} if $_->{KEYNAME} =~ /^TAG$/;
    }
}

if (-f $configdir."/ocsinventory-agent.cfg") {
    open (CONFIG, "<".$configdir."/ocsinventory-agent.cfg") or
    die "Can't open ".$configdir."/ocsinventory-agent.cfg: ".$!;

    foreach (<CONFIG>) {
        s/#.+//;
        if (/(\w+)\s*=\s*(.+)/) {
            my $key = $1;
            my $val = $2;
            # Remove the quotes
            $val =~ s/\s+$//;
            $val =~ s/^'(.*)'$/$1/;
            $val =~ s/^"(.*)"$/$1/;
            $config->{$key} = $val;
        }
    }
    close CONFIG;
}

print "[info] The config file will be written in /etc/ocsinventory/ocsinventory-agent.cfg,\n";

$config->{server} = prompt('What is the address of your ocs server', exists ($config->{server})?$config->{server}:'ocsinventory-ng');
if (!$config->{server}) {
    print "Server is empty. Leaving...\n";
    exit 1;
}
my $uri;
if ($config->{server} =~ /^http(|s):\/\//) {
    $uri = $config->{server};
} else { # just the hostname
    $uri = "http://".$config->{server}."/ocsinventory"
}

if (ask_yn ("Do you need credential for the server? (You probably don't)")) {
    $config->{user} = prompt("user".(exists($config->{user})?"(".$config->{user}.")":'' ));
    $config->{password} = prompt("password");
    print "[info] The realm can be found in the login popup of your Internet browser.\n[info] In general, it's something like 'Restricted Area'.\n";
    $config->{realm} = prompt("realm");
} else {
    delete ($config->{user});
    delete ($config->{password});
    delete ($config->{realm});
}

if (ask_yn('Do you want to apply an administrative tag on this machine')) {

    $config->{tag} = prompt("tag".(exists($config->{tag})?"(".$config->{tag}.")":'' ));
} else {
    delete($config->{tag});
}

my $binpath;
foreach (qw(/usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /opt/ocsinventory-agent/bin) ) {
    $binpath = $_.'/ocsinventory-agent';
    last if -x $binpath;
}

if (! -x $binpath) {
    print "sorry, ocsinventory-agent is not installed in a standard directory\n";
    exit 1;
} else {
    print "ocsinventory agent presents: $binpath\n";
}

if (-d "/etc/cron.d") {
    if (ask_yn("Do yo want to install the cron task in /etc/cron.d")) {
        my $randomtime = int(rand(60)).' '.int(rand(24));

        open DEST, '>/etc/cron.d/ocsinventory-agent' or die $!;
        print  DEST $randomtime." * * * root $binpath --lazy > /dev/null 2>&1\n";
        close DEST;
    }
}


$config->{basevardir} = prompt('Where do you want the agent to store its files?', exists ($config->{basevardir})?$config->{basevardir}:'/var/lib/ocsinventory-agent', '/^\/\w+/', 'The location must begin with /');

if (!-d $config->{basevardir}) {
    if (ask_yn ("Do you want to create the ".$config->{basevardir}." directory?\n")) {
        mkdir $config->{basevardir} or die $!;
    } else {
        print "Please create the ".$config->{basevardir}." directory\n";
        exit 1;
    }
}

open CONFIG, ">$configdir/ocsinventory-agent.cfg" or die "Can't write the config file in $configdir: ".$!;
print CONFIG $_."=".$config->{$_}."\n" foreach (keys %$config);
close CONFIG;
chmod 0600, "$configdir/ocsinventory-agent.cfg";

print "New settings written! Thank you for using OCS Inventory\n";

if (ask_yn ("Should I remove the old linux_agent")) {
    foreach (qw#
        /etc/ocsinventory-client
        /etc/logtotate.d/ocsinventor-client
        /usr/sbin/ocsinventory-client.pl
        /bin/ocsinv
        #) {
        print $_."\n";
        next;
        rmdir if -d;
        unlink if -f || -l;
    }
    print "done\n"
}

# Create the vardirectory for this server
my $dir = $config->{server};
$dir =~ s/\//_/g;
my $vardir = $config->{basevardir}."/".$dir;
recMkdir($vardir) or die "Can't create $vardir!";

if (@cacert) { # we need to migrate the certificat
    open CACERT, ">".$vardir."/cacert.pem" or die "Can't open ".$vardir.'/cacert.pem: '.$!;
    print CACERT foreach (@cacert);
    close CACERT;
    print "Certificat copied in ".$vardir."/cacert.pem\n";
}

my $download_enable = ask_yn("Do you want to use OCS-Inventory software deployment feature?");

open MODULE, ">$configdir/modules.conf" or die "Can't write modules.conf in $configdir: ".$!;
print MODULE "# this list of module will be load by the at run time\n";
print MODULE "# to check its syntax do:\n";
print MODULE "# #perl modules.conf\n";
print MODULE "# You must have NO error. Else the content will be ignored\n";
print MODULE "# This mechanism goal it to keep compatibility with 'plugin'\n";
print MODULE "# created for the previous linux_agent.\n";
print MODULE "# The new unified_agent have its own extension system that allow\n";
print MODULE "# user to add new information easily.\n";
print MODULE "\n";
print MODULE ($download_enable?'#':'');
print MODULE "use Ocsinventory::Agent::Option::Download;\n";
print MODULE "\n";
print MODULE "# DO NO REMOVE the 1;\n";
print MODULE "1;\n";
close MODULE;


if (ask_yn("Do you want to send an inventory of this machine?")) {
    #system("$binpath --force");
    system("./ocsinventory-agent --force");
    if (($? >> 8)==0) {
        print "   -> Success!\n";
    } else {
        print "   -> Failed!\n";
    }
}
