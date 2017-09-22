package FusionInventory::Agent::Task::Wmi;
use strict;
use warnings FATAL => 'all';
use parent 'FusionInventory::Agent::Task::Inventory';

use UNIVERSAL::require;
use English qw(-no_match_vars);
use Data::Dumper;

use FusionInventory::Agent::Tools::Win32;

our $VERSION = '0.1';

sub isEnabled {
    my ($self) = @_;

    return unless (
        $self->{config}->{wmi_hostname}
        && $self->{config}->{wmi_user}
        && $self->{config}->{wmi_pass}
    );


    return 1;
}

sub getModules {
    #TODO : overwrite...
}

sub run {
    my ( $self, %params ) = @_;

    $self->{logger}->debug2('running Wmi') if $self->{logger};

    $params{enabledModules} = [
        'FusionInventory::Agent::Task::Inventory::Generic',
        'FusionInventory::Agent::Task::Inventory::Generic::Screen',
        'FusionInventory::Agent::Task::Inventory::Virtualization',
        'FusionInventory::Agent::Task::Inventory::Virtualization::HyperV',
        'FusionInventory::Agent::Task::Inventory::Win32',
        'FusionInventory::Agent::Task::Inventory::Win32::AntiVirus',
        'FusionInventory::Agent::Task::Inventory::Win32::Bios',
        'FusionInventory::Agent::Task::Inventory::Win32::Chassis',
        'FusionInventory::Agent::Task::Inventory::Win32::Controllers',
        'FusionInventory::Agent::Task::Inventory::Win32::CPU',
        'FusionInventory::Agent::Task::Inventory::Win32::Drives',
        'FusionInventory::Agent::Task::Inventory::Win32::Environment',
        'FusionInventory::Agent::Task::Inventory::Win32::Firewall',
        'FusionInventory::Agent::Task::Inventory::Win32::Inputs',
        'FusionInventory::Agent::Task::Inventory::Win32::License',
        'FusionInventory::Agent::Task::Inventory::Win32::Memory',
        'FusionInventory::Agent::Task::Inventory::Win32::Modems',
        'FusionInventory::Agent::Task::Inventory::Win32::Networks',
        'FusionInventory::Agent::Task::Inventory::Win32::OS',
        'FusionInventory::Agent::Task::Inventory::Win32::Ports',
        'FusionInventory::Agent::Task::Inventory::Win32::Printers',
        'FusionInventory::Agent::Task::Inventory::Win32::Registry',
        'FusionInventory::Agent::Task::Inventory::Win32::Slots',
        'FusionInventory::Agent::Task::Inventory::Win32::Softwares',
        'FusionInventory::Agent::Task::Inventory::Win32::Sounds',
        'FusionInventory::Agent::Task::Inventory::Win32::Storages',
        'FusionInventory::Agent::Task::Inventory::Win32::USB',
        'FusionInventory::Agent::Task::Inventory::Win32::Users',
        'FusionInventory::Agent::Task::Inventory::Win32::Videos'
    ];
    $params{WMIService} = {
        hostname => $self->{config}->{wmi_hostname},
        user     => $self->{config}->{wmi_user},
        pass     => $self->{config}->{wmi_pass},
        locale   => $self->{config}->{wmi_locale} || '',
    };
    my $service = getWMIService(%params);
    die "can't connect to host $params{WMIService}->{hostname} with credentials and locale '$params{WMIService}->{locale}'\n"
        unless $service;
    $params{WMIService}->{locale} = getRemoteLocaleFromWMI(%params) unless $params{WMIService}->{locale};
    $self->{logger}->debug2('using locale: ' . $params{WMIService}->{locale}) if $self->{logger};

    $self->SUPER::run(%params);
}

sub getCPU {
    my @cpus = FusionInventory::Agent::Tools::Win32::getWMIObjects(
        class      => 'Win32_Processor',
        returnAllPropertiesValues => 1,
        @_
    );

    return @cpus;
}

1;
