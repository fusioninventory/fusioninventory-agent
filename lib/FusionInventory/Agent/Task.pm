package FusionInventory::Agent::Task;

use strict;
use warnings;


sub new {
    my ($class, %params) = @_;

    my $self = {
        id            => $params{id},
    };
    bless $self, $class;

    return $self;
}

sub getPrologResponse {
    my ($self, %params) = @_;

    my $prolog = FusionInventory::Agent::XML::Query::Prolog->new(
        logger   => $self->{logger},
        deviceid => $params{deviceid},
        token    => $params{token}
    );

    if ($params{tag}) {
        $prolog->setAccountInfo(TAG => $params{tag});
    }

    return $params{transmitter}->send(
        message => $prolog,
        url     => $params{url}
    );
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

FusionInventory::Agent::Task - Abstract task

=head1 DESCRIPTION

A task is a specific work to execute.

=head1 METHODS

=head2 new(%params)

The constructor. See subclass documentation for parameters.

=head2 run(%params)

Run the task. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use

=item I<target>

=item I<confdir>

=item I<datadir>

=item I<deviceid>

=item I<token>

=back

=head2 getPrologResponse(%params)

Establish preliminary dialog with a server target, and returns server response.

The following parameters are allowed, as keys of the %params
hash:

=over

=item I<logger>

the logger object to use

=item I<deviceid>

=item I<token>

=item I<url>

=item I<tag>

=back

=head2 getModules()

Return a list of modules for this task.
