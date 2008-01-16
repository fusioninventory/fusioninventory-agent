#!/usr/bin/perl -w

use strict;

use LWP::Simple;

my $configdir = "/etc/ocsinventory";

my %config;

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
    my ($prompt, $default) = @_;

    print $prompt;
    print "($default)" if $default;
    print "?:\n";
    chomp(my $line = <STDIN>);

    return $line;
}

if (!ask_yn("Do you want to configure the agent")) {
    exit 0;
}
print "[note] The config file will be written in /etc/ocsinventory/ocsinventory-agent.cfg,\n";
print "[note] consider moving the directory in /usr/local/etc if you run a *BSD system\n";

$config{server} = prompt('What is the address of your ocs server', 'ocsinventory-ng');
if (!$config{server}) {
    print "Server is empty. Leaving...";
    exit 1;
}
my $uri;
if ($config{server} =~ /^http(|s):\/\//) {
    $uri = $config{server};
} else { # just the hostname
    $uri = "http://".$config{server}."/ocsinventory"
}

if (head($uri)) {
print "Can't contact $uri\n";
exit 1;
}
print "Ok, server found at $uri\n";

if (ask_yn('Do you want to apply an administrative tag on this machine')) {

$config{tag} = prompt('tag');
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

if (ask_yn ("Do you need credential for the server? (You probably don't)")) {
    while (!$config{user}) {
        $config{user} = prompt("user");
    }
    $config{password} = prompt("password");
    print "[note] The realm can be found in the login popup of your Internet browser.\n[note] In general, it's something like 'Restricted Area'.\n";
    $config{password} = prompt("realm");
}

if (-d "/etc/cron.d") {
    if (ask_yn("Do yo want to install the cron task in /etc/cron.d")) {
        my $randomtime = int(rand(60)).' '.int(rand(24));
        foreach (qw( blib/etc blib/etc/cron.d )) {
            next if -d;
            mkdir $_ or die $!;
        }
        open DEST, '>/etc/cron.d/ocsinventory-agent' or die $!;
        print  DEST $randomtime." * * * root $binpath > /dev/null 2>&1\n";
        close DEST;
    }
}

if (!-d $configdir) {
    mkdir $configdir or die $!;
}

open CONFIG, ">$configdir/ocsinventory-agent.cfg" or die "Can't write the config file in $configdir: ".$!;
print CONFIG $_."=".$config{$_}."\n" foreach (keys %config);
close CONFIG;
print "New settings written! Thank you for using OCS Inventory\n";

if (-d "/etc/ocsinventory-client" && ask_yn ("Should I remove the config directory of the old linux agent")) {
    system ('rm -r /etc/ocsinventory-client');
    print "done\n";
}
