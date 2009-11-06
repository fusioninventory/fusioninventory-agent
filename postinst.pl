#!/usr/bin/perl -w

use strict;

use lib 'lib';

use Ocsinventory::Agent::Config;


my $old_linux_agent_dir = "/etc/ocsinventory-client";

my $config;
my @cacert;
my $binpath;
my $randomtime;
my $cron_line;

sub loadModules {
    my @modules = @_;

    foreach (@modules) {
        eval "use $_;";
        if ($@) {
            print STDERR "Failed to load $_. Please install it and restart the postinst.pl script ( ./postinst.pl ).\n";
            exit 1;

        }
    }

}

sub ask_yn {
    my $promptUser = shift;
    my $default = shift;

    die unless $default =~ /^(y|n)$/;

    my $cpt = 5;
    while (1) {
        my $line = prompt("$promptUser\nPlease enter 'y' or 'n'?>", $default);
        return 1 if $line =~ /^y$/;
        return if $line =~ /^n$/;
        if ($cpt-- < 0) {
            print STDERR "to much user input, exit...\n";
            exit(0);
        }
    }
}

sub promptUser {
    my ($promptUser, $default, $regex, $notice) = @_;

    my $string = $promptUser;
    $string .= "?>";

    my $line;
    my $cpt = 5;
    while (1) {

        $line = prompt($string, $default);

        if ($regex && $line !~ /$regex/) {
            print STDERR $notice."\n";
        } else {
            last;
        }

        if ($cpt-- < 0) {
            print STDERR "to much user input, exit...\n";
            exit(0);
        }

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

    print STDERR "Where do you want to write the configuration file?\n";
    foreach (0..$#choices) {
        print STDERR " ".$_." -> ".$choices[$_]."\n";
    }
    my $input = -1;
    my $configdir;
    while (1) {
        $input = prompt("?>");
        if ($input =~ /^\d+$/ && $input >= 0 && $input <= $#choices) {
            last;
        } else {
            print STDERR "Value must be between 0 and ".$#choices."\n";
        }
    }


    if (! -d $choices[$input]) {
        if (ask_yn ("Do you want to create the directory ".$choices[$input]."?", 'y')) {
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

sub mkFullServerUrl {

    my $server = shift;

    my $ret = 'http://' unless $server =~ /^http(s|):\/\//;
    $ret .= $server;
   
    if ($server !~ /http(|s):\/\/\S+\/\S+/) {
        $ret .= '/ocsinventory';
    }

    return $ret;

}


####################################################
################### main ###########################
####################################################

loadModules (qw/XML::Simple ExtUtils::MakeMaker/);

if (!ask_yn("Do you want to configure the agent", 'y')) {
    exit 0;
}


my $configdir = pickConfigdir ("/etc/ocsinventory", "/usr/local/etc/ocsinventory", "/etc/ocsinventory-agent");

if (-f $old_linux_agent_dir.'/ocsinv.conf' && ask_yn("Should the old linux_agent settings be imported?", 'y')) {
    my $ocsinv = XMLin($old_linux_agent_dir.'/ocsinv.conf');
    $config->{server} = mkFullServerUrl($ocsinv->{'OCSFSERVER'});

    if (-f $old_linux_agent_dir.'/cacert.pem') {
        open CACERT, $old_linux_agent_dir.'/cacert.pem' or die "Can'i import the CA certificat: ".$!;
        @cacert = <CACERT>;
        close CACERT;
    }

    my $admcontent = '';


    if (-f "$old_linux_agent_dir/ocsinv.adm") {
        if (!open(ADM, "<:encoding(iso-8859-1)", "$old_linux_agent_dir/ocsinv.adm")) {
            warn "Can't open $old_linux_agent_dir/ocsinv.adm";
        } else {
            $admcontent .= $_ foreach (<ADM>);
            close ADM;
            my $admdata = XMLin($admcontent) or die;
            if (ref ($admdata->{ACCOUNTINFO}) eq 'ARRAY') {
                foreach (@{$admdata->{ACCOUNTINFO}}) {
                    $config->{tag} = $_->{KEYVALUE} if $_->{KEYNAME} =~ /^TAG$/;
                }
            } elsif (
                exists($admdata->{ACCOUNTINFO}->{KEYNAME}) &&
                exists($admdata->{ACCOUNTINFO}->{KEYVALUE}) &&
                $admdata->{ACCOUNTINFO}->{KEYNAME} eq 'TAG'
            ) {
                print $admdata->{ACCOUNTINFO}->{KEYVALUE}."\n";
                $config->{tag} = $admdata->{ACCOUNTINFO}->{KEYVALUE};
            }
        }
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

my $tmp = promptUser('What is the address of your ocs server', exists ($config->{server})?$config->{server}:'ocsinventory-ng');
$config->{server} = mkFullServerUrl($tmp);
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

if (ask_yn ("Do you need credential for the server? (You probably don't)", 'n')) {
    $config->{user} = promptUser("user", $config->{user});
    $config->{password} = promptUser("password");
    print "[info] The realm can be found in the login popup of your Internet browser.\n[info] In general, it's something like 'Restricted Area'.\n";
    $config->{realm} = promptUser("realm");
} else {
    delete ($config->{user});
    delete ($config->{password});
    delete ($config->{realm});
}

if (ask_yn('Do you want to apply an administrative tag on this machine', 'y')) {

    $config->{tag} = promptUser("tag", $config->{tag});
} else {
    delete($config->{tag});
}


chomp($binpath = `which ocsinventory-agent 2>/dev/null`);
if (! -x $binpath) {
	# Packaged version with perl and agent ?
	$binpath = $^X;
	$binpath =~ s/perl/ocsinventory-agent/;
}

if (! -x $binpath) {
    print "sorry, can't find ocsinventory-agent in \$PATH\n";
    exit 1;
} else {
    print "ocsinventory agent presents: $binpath\n";
}


$randomtime = int(rand(60)).' '.int(rand(24));
$cron_line = $randomtime." * * * root $binpath --lazy > /dev/null 2>&1\n";

if ($^O =~ /solaris/) {
    if (ask_yn("Do yo want to install the cron task in current user crontab ?", 'y')) {
	my $crontab = `crontab -l`;

	# Let's suppress Linux cron/anacron user column
	$cron_line =~ s/ root /  /;
	$crontab .= $cron_line;

	open CRONP, "| crontab" || die "Can't run crontab: $!";
	print CRONP $crontab;
	close(CRONP);

    }
}
elsif (-d "/etc/cron.d") {
    if (ask_yn("Do yo want to install the cron task in /etc/cron.d", 'y')) {

        open DEST, '>/etc/cron.d/ocsinventory-agent' or die $!;
        # Save the root PATH
        print DEST "PATH=".$ENV{PATH}."\n";
        print DEST $randomtime." * * * root $binpath --lazy > /dev/null 2>&1\n";
        close DEST;
    }
}

my $default_vardir;
if ($^O =~ /solaris/) {
	$default_vardir = '/var/opt/ocsinventory-agent';
} else { 
	$default_vardir = '/var/lib/ocsinventory-agent'
}
	
$config->{basevardir} = promptUser('Where do you want the agent to store its files? (You probably don\'t need to change it)', exists ($config->{basevardir})?$config->{basevardir}:$default_vardir, '^\/\w+', 'The location must begin with /');

if (!-d $config->{basevardir}) {
    if (ask_yn ("Do you want to create the ".$config->{basevardir}." directory?\n", 'y')) {
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

if (ask_yn ("Should I remove the old linux_agent", 'n')) {
    foreach (qw#
        /etc/ocsinventory-client
        /etc/logtotate.d/ocsinventor-client
        /usr/sbin/ocsinventory-client.pl
        /etc/cron.d/ocsinventory-client
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

my $download_enable = ask_yn("Do you want to use OCS-Inventory software deployment feature?", 'y');

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
print MODULE ($download_enable?'':'#');
print MODULE "use Ocsinventory::Agent::Option::Download;\n";
print MODULE "\n";
print MODULE "# DO NOT REMOVE THE 1;\n";
print MODULE "1;\n";
close MODULE;


if (ask_yn("Do you want to send an inventory of this machine?", 'y')) {
    system("$binpath --force");
    if (($? >> 8)==0) {
        print "   -> Success!\n";
    } else {
        print "   -> Failed!\n";
	print "You may want to launch the agent with the --verbose or --debug flag.\n";
    }
}
