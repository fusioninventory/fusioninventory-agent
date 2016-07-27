package FusionInventory::Agent::Task::Inventory::Solaris::Softwares;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    my (%params) = @_;

    return
        !$params{no_category}->{software} &&
        (canRun('pkg') || canRun('pkginfo'));
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle;
    
    my $usepkg = 0;
    $usepkg = 1 if (canRun('pkg'));
    
    if ($usepkg) {
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
    if ($usepkg) {
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
