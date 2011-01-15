package FusionInventory::Test::MockSystem;

use strict;
use warnings;
use base 'Exporter';

use FusionInventory::Agent::Tools;

our @EXPORT = qw(
    mockSystem
    mockCanRun
    mockCanRead
    mockGetFileHandle
);

sub mockSystem {
    my (%params) = @_;


    mockGetFileHandle(%params);

    mockCanRead(files => $params{files});

    # compute a list of available executables
    my %executables =
        map { $_ => 1 }
        map { (split (' ', $_))[0] }
        keys %{$params{commands}};

    mockCanRun(commands => \%executables);
}

sub mockGetFileHandle {
    my (%params) = @_;

    my $old = \&FusionInventory::Agent::Tools::getFileHandle;

    my $new = sub {
        my (%options) = @_;

        my $file;

        if ($options{command}) {
            my $wanted = $options{command};
            print STDERR "command '$wanted' wanted: ";
            $file = $params{commands}->{$wanted};
        }

        if ($options{file}) {
            my $wanted = $options{file};
            print STDERR "file '$wanted' wanted: ";
            $file = $params{files}->{$wanted};
        }

        if ($file) {
            print STDERR "file '$file' delivered\n";
            return $old->(@_, file => $file);
        } else {
            print STDERR "nothing delivered\n";
            return;
        }
    };

    no warnings 'redefine';
    *FusionInventory::Agent::Tools::getFileHandle = $new;
}

sub mockCanRun {
    my (%params) = @_;

    my $new = sub {
        my $wanted = $_[0];
        print STDERR
            "command '$wanted' availability tested: "  .
            ($params{commands}->{$wanted} ? "true" : "false") .
            "\n";

        return $params{commands}->{$wanted};
    };

    no warnings 'redefine';
    *FusionInventory::Agent::Tools::can_run = $new;
}

sub mockCanRead {
    my (%params) = @_;

    my $new = sub {
        my $wanted = $_[0];
        print STDERR
            "file '$wanted' availability tested: "  .
            ($params{files}->{$wanted} ? "true" : "false") .
            "\n";

        return $params{files}->{$wanted};
    };

    no warnings 'redefine';
    *FusionInventory::Agent::Tools::can_read = $new;
}

1
