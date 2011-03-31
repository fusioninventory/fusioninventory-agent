package FusionInventory::Agent::Task;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Find;

use FusionInventory::Agent::Logger;

sub new {
    my ($class, $params) = @_;

    die 'no target parameter' unless $params->{target};

    my $self = {
        logger      => $params->{logger} ||
                       FusionInventory::Agent::Logger->new(),
        config      => $params->{config},
        confdir     => $params->{confdir},
        datadir     => $params->{datadir},
        target      => $params->{target},
        prologresp  => $params->{prologresp},
        transmitter => $params->{transmitter},
        deviceid    => $params->{deviceid}
    };
    bless $self, $class;

    return $self;
}

sub getModules {
    my ($class) = @_;

    # use %INC to retrieve the root directory for this task
    my $file = _module2file($class);
    my $rootdir = $INC{$file};
    $rootdir =~ s/.pm$//;
    return unless -d $rootdir;

    # find a list of modules from files in this directory
    my $root = $file;
    $root =~ s/.pm$//;
    my @modules;
    my $wanted = sub {
        return unless -f $_;
        return unless $File::Find::name =~ m{($root/\S+\.pm)$};
        my $module = _file2module($1);
        push(@modules, $module);
    };
    File::Find::find($wanted, $rootdir);
    return @modules
}

sub _file2module {
    my ($file) = @_;
    $file =~ s{.pm$}{};
    $file =~ s{/}{::}g;
    return $file;
}

sub _module2file {
    my ($module) = @_;
    $module .= '.pm';
    $module =~ s{::}{/}g;
    return $module;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task - Base class for agent task

=head1 DESCRIPTION

This is an abstract class for all task performed by the agent.

=head1 METHODS

=head2 new($params)

The constructor. The following parameters are allowed, as keys of the $params
hashref:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<config>

=item I<target>

=item I<storage>

=item I<prologresp>

=item I<transmitter>

=item I<deviceid>

=back

=head2 main()

This is the method to be implemented by each subclass.

=head2 getModules()

Return a list of modules for this task.
