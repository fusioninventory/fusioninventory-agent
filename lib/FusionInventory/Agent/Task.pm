package FusionInventory::Agent::Task;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Find;

use FusionInventory::Agent;
use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Logger;

sub new {
    my ($class, %params) = @_;

    my $self = {
        logger       => $params{logger} ||
                        FusionInventory::Agent::Logger->new(),
        config       => $params{config},
        confdir      => $params{confdir},
        datadir      => $params{datadir},
        controller   => $params{controller},
        deviceid     => $params{deviceid},
    };
    bless $self, $class;

    return $self;
}

sub configure {
    my ($self, %params) = @_;

    foreach my $key (keys %params) {
        $self->{params}->{$key} = $params{$key};
    }
}

sub setParam {
    my ($self, $name, $value) = @_;

    $self->{params}->{$name} = $value;
}

sub getModules {
    my ($class, $prefix) = @_;

    # allow to be called as an instance method
    $class = ref $class ? ref $class : $class;

    # use %INC to retrieve the root directory for this task
    my $file = module2file($class);
    my $rootdir = $INC{$file};
    $rootdir =~ s/.pm$//;
    return unless -d $rootdir;

    # find a list of modules from files in this directory
    my $root = $file;
    $root =~ s/.pm$//;
    $root .= "/$prefix" if $prefix;
    my @modules;
    my $wanted = sub {
        return unless -f $_;
        return unless $File::Find::name =~ m{($root/\S+\.pm)$};
        my $module = file2module($1);
        push(@modules, $module);
    };
    File::Find::find($wanted, $rootdir);
    return @modules
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Task - Base class for agent task

=head1 DESCRIPTION

This is an abstract class for all task performed by the agent.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use (default: a new stderr logger)

=item I<config>

=item I<controller>

=item I<storage>

=item I<prologresp>

=item I<client>

=item I<deviceid>

=back

=head2 isEnabled()

This is a method to be implemented by each subclass.

=head2 run()

This is a method to be implemented by each subclass.

=head2 getOptionsFromServer($response, $name, $feature)

Get task-specific options in server response to prolog message.

=head2 getModules($prefix)

Return a list of modules for this task. All modules installed at the same
location than this package, belonging to __PACKAGE__ namespace, will be
returned. If optional $prefix is given, base search namespace will be
__PACKAGE__/$prefix instead.
