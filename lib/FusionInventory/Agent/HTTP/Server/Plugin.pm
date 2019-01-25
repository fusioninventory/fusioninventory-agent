package FusionInventory::Agent::HTTP::Server::Plugin;

use strict;
use warnings;

use base "FusionInventory::Agent::Config";

use Cwd qw(abs_path);

use FusionInventory::Agent::Tools;

sub new {
    my ($class, %params) = @_;

    my ($name) = $class =~ /::(\w+)$/;

    my $self = {
        logger  => $params{server}->{logger} ||
                    FusionInventory::Agent::Logger->new(),
        server  => $params{server},
        name    => $name,
    };

    bless $self, $class;

    # Check _confdir imported from FusionInventory::Agent::Config
    unless ($self->{_confdir} && -d $self->{_confdir}) {
        # Set absolute confdir from default if replaced by Makefile otherwise search
        # from current path, mostly useful while running from source
        $self->{_confdir} = abs_path(File::Spec->rel2abs(
            $self->{_confdir} || first { -d $_ } qw{ ./etc  ../etc }
        ));
    }

    return $self;
}

sub init {
    my ($self) = @_;

    $self->debug("Initializing ".$self->{name}." Server plugin...");

    if ($self->confdir() && $self->config_file()) {
        my $config = $self->confdir().'/'.$self->config_file();
        if (-f $config && -r $config) {
            $self->debug("Loading ".$self->{name}." Server plugin configuration from $config");
            # Load defaults
            my $defaults = $self->defaults();
            foreach my $param (keys(%{$defaults})) {
                $self->{$param} = $defaults->{$param};
            }
            # Load configuration file
            $self->loadFromFile({file => $config, defaults => $defaults});
        }
    }
}

# Plugins with greater priority values are used first
sub priority { 10 }

sub name {
    my ($self) = @_;
    return $self->{name};
}

# Defaults must be a key-value pair list ref is a config file is to be read
sub defaults {
    return {};
}

sub port {
    my ($self) = @_;
    return $self->{port}
        if ($self->{port} && $self->{port} =~ /^\d+$/ && $self->{port} < 65536);
    return 0;
}

# A plugin can be disabled by configuration or by server
sub disabled {
    my ($self, $yesno) = @_;
    return $self->{disabled} ? 1 : 0 ;
}

sub disable {
    my ($self) = @_;
    $self->{disabled} = 1;
    $self->info("plugin disabled");
}

sub log_prefix {
    return "[http server plugin] ";
}

sub info {
    my ($self, $message) = @_;
    return unless $self->{logger};
    $self->{logger}->info( $self->log_prefix() . $message );
}

sub debug {
    my ($self, $message) = @_;
    return unless $self->{logger};
    $self->{logger}->debug( $self->log_prefix() . $message );
}

sub debug2 {
    my ($self, $message) = @_;
    return unless $self->{logger};
    $self->{logger}->debug2( $self->log_prefix() . $message );
}

sub config {
    my ($self, $name) = @_;
    return $self->{$name};
}

sub config_file {}

sub urlMatch {}

sub handle {}

1;
__END__

=head1 NAME

FusionInventory::Agent::HTTP:Server::Plugin - A class template for embedded HTTP server plugins

=head1 DESCRIPTION

This is a template class to base on FusionInventory::Agent::HTTP:Server plugins.

Plugins purpose is to handle specific requets.

=head1 CLASS METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<server>

the associated server

=back

=head1 INSTANCE METHODS

=head2 $plugin->urlMatch($path)

Returns true if the passed path match the plugin expected URL pattern.

=head2 $plugin->handle($client, $request, $clientIp)

Handles the matching incoming request.

=head2 $plugin->priority()

Returns plugin priority against any other plugin (default = 10).

Greater priority makes the plugin be used befores lower priority plugins.

=head2 $plugin->log_prefix()

Should return a log prefix to be used in logging for a plugin.

=head2 $plugin->config_file()

Can return config filename to be loaded from the config dir, none by default.

Config file can contain any key/value pair like the normal agent configuration
file. Even include directive could be used. No validation is done during the
configuration load. The plugin should carefully check loaded values when used.

=head2 $plugin->init()

Initializes a plugin, by default, this loads a configuration file if defined and found.

=head2 $plugin->config($name)

Returns the loaded configuration value for the given value name.

=head2 $plugin->info($message)

Log information level message using log_prefix

=head2 $plugin->debug($message)

Log debug level message using log_prefix

=head2 $plugin->debug2($message)

Log debug2 level message using log_prefix
