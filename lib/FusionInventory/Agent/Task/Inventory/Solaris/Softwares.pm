package FusionInventory::Agent::Task::Inventory::Solaris::Softwares;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Solaris;

sub isEnabled {
    my (%params) = @_;

    my $info = getReleaseInfo();
    if ($info->{version} > 10) {
    	return
    	    !$params{no_category}->{software} &&
    	    canRun('pkg');
    } else {
    	return
    	    !$params{no_category}->{software} &&
    	    canRun('pkginfo');
    }
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle;
    my $info = getReleaseInfo();
    if ($info->{version} > 10) {
    	$handle = getFileHandle(
    	    command => 'pkg info',
    	    logger  => $logger,
    	);
    } else {
    	$handle = getFileHandle(
    	    command => 'pkginfo -l',
    	    logger  => $logger,
    	);
    }

    return unless $handle;

    my $software;
    if ($info->{version} > 10) {
    	while (my $line = <$handle>) {
    	    if ($line =~ /^\s*$/) {
        		$inventory->addEntry(
        		    section => 'SOFTWARES',
        		    entry   =>  $software
        		);
    		    undef $software;
    	    } elsif ($line =~ /Name:\s+(.+)/) {
    		    $software->{NAME} = $1;
    	    } elsif ($line =~ /FMRI:\s+.+\@(.+)/) {
    		    $software->{VERSION} = $1;
    	    } elsif ($line =~ /Publisher:\s+(.+)/) {
    		    $software->{PUBLISHER} = $1;
    	    } elsif ($line =~  /Summary:\s+(.+)/) {
    		    $software->{COMMENTS} = $1;
    	    }
    	}
    } else {
    	while (my $line = <$handle>) {
    	    if ($line =~ /^\s*$/) {
        		$inventory->addEntry(
        		    section => 'SOFTWARES',
        		    entry   =>  $software
        		);
        		undef $software;
    	    } elsif ($line =~ /PKGINST:\s+(.+)/) {
        		$software->{NAME} = $1;
    	    } elsif ($line =~ /VERSION:\s+(.+)/) {
        		$software->{VERSION} = $1;
    	    } elsif ($line =~ /VENDOR:\s+(.+)/) {
        		$software->{PUBLISHER} = $1;
    	    } elsif ($line =~  /DESC:\s+(.+)/) {
        		$software->{COMMENTS} = $1;
    	    }
    	}
    }

    close $handle;
}

1;
