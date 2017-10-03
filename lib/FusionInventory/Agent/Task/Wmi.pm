package FusionInventory::Agent::Task::Wmi;

use strict;
use warnings;
use parent 'FusionInventory::Agent::Task::Inventory';

use constant SUPPORTED => map {
    "FusionInventory::Agent::Task::Inventory::$_"
} qw(
        Generic::Screen
        Virtualization
        Virtualization::HyperV
        Win32
        Win32::AntiVirus
        Win32::Bios
        Win32::Chassis
        Win32::Controllers
        Win32::CPU
        Win32::Drives
        Win32::Environment
        Win32::Firewall
        Win32::Inputs
        Win32::License
        Win32::Memory
        Win32::Modems
        Win32::Networks
        Win32::OS
        Win32::Ports
        Win32::Printers
        Win32::Registry
        Win32::Slots
        Win32::Softwares
        Win32::Sounds
        Win32::Storages
        Win32::USB
        Win32::Users
        Win32::Videos
    );

use UNIVERSAL::require;
use English qw(-no_match_vars);

use FusionInventory::Agent::Tools::Win32;

sub isEnabled {
    my ($self) = @_;

    # TODO Fix to handle requests from server
    return defined $self->{service};
}

sub getModules {
    # List of Inventory modules we support for wmi inventory
    return (SUPPORTED);
}

sub isWmi {
    1;
}

sub connect {
    my ( $self, %params ) = @_;

    my $host   = $params{host} || '127.0.0.1';
    my $user   = $params{user} || '';
    my $pass   = $params{pass} || '';
    my $locale = $params{locale} || '';

    $self->{logger}->debug2('connect to Wmi: $user@$host') if $self->{logger};

    $self->{service} = getWMIService(
        host    => $host,
        user    => $user,
        pass    => $pass,
        locale  => $locale
    );

    die "can't connect to host $host with $user credentials and locale '$locale'\n"
        unless $self->{service};

    return unless $self->{logger};

    # Only for advanced debugging
    if (!$locale) {
        $locale = getRemoteLocaleFromWMI() unless $locale;
        $self->{logger}->debug2(
            $locale ? "found remote locale: $locale" : "No remote locale found"
        );
    }
}

1;
