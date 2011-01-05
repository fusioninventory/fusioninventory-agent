package FusionInventory::Test::MockSystem;

use strict;
use warnings;

use Hook::LexWrap;
use FusionInventory::Agent::Tools;

sub new {
    my ($class, %params) = @_;

    # compute a list of available executables
    my %executables =
        map { $_ => 1 }
        map { (split (' ', $_))[0] }
        keys %{$params{commands}};

    my $self = {};
    bless $self, $class;

    wrap 'FusionInventory::Agent::Tools::getFileHandle', pre => getFileHandleWrapper(%params);

    wrap 'FusionInventory::Agent::Tools::can_run', pre => getAvailabilityWrapper(
        type => 'command',
        items => \%executables
    );

    wrap 'FusionInventory::Agent::Tools::can_read', pre => getAvailabilityWrapper(
        type => 'file',
        items => $params{files}
    );

    return $self;
}

sub getFileHandleWrapper {
    my (%params) = @_;

    my $original = \&{'FusionInventory::Agent::Tools::getFileHandle'};

    return sub {
        # scan arguments
        foreach my $i (0 .. $#_) {
            next unless $_[$i] && $_[$i + 1];

            if ($_[$i] eq 'command') {
                my $wanted = $_[$i + 1];
                print STDERR "command '$wanted' wanted\n";

                # check if a mock output exists
                my $replacement = $params{commands}->{$wanted};
                next unless $replacement;

                # short-circuit original function
                $_[-1] = $original->(@_[0 .. $#_ -1],  file => $replacement);
                print STDERR
                    "command '$wanted' replaced with file '$replacement'\n";
                return;
            }

            if ($_[$i] eq 'file') {
                my $wanted = $_[$i + 1];
                print STDERR "file '$wanted' wanted\n";

                # check if a mock content exists
                my $replacement = $params{files}->{$wanted};
                next unless $replacement;

                # short-circuit original function
                $_[-1] = $original->(@_[0 .. $#_ -1],  file => $replacement);
                print STDERR
                    "file '$wanted' replaced with file '$replacement'\n";
                return;
            }
        }
    };
}

sub getAvailabilityWrapper {
    my (%params) = @_;

    return sub {
        my $wanted = $_[0];
        print STDERR
            "$params{type} '$wanted' availability tested: "  .
            ($params{items}->{$wanted} ? "true" : "false") .
            "\n";

        # short-circuit original function
        $_[1] = $params{items}->{$wanted};
    };
}

1
