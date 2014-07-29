package FusionInventory::Agent::Task::Inventory::Virtualization::Hyperv;

use strict;
use warnings;
use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('wmic');
}

my $host = FusionInventory::Agent::Tools::Hostname::getHostname();
   $host = $ENV{COMPUTERNAME} unless $host;
if ($host  =~ s/^([^\.]+)\.(.*)/$1/) { $host = $1; }

sub doInventory {
    my (%params) = @_;
    my $inventory = $params{inventory};
    my $logger    = $params{inventory};
    my $command = 'wmic /namespace:\\\root\\Virtualization path MSVM_ComputerSystem get ElementName, EnabledState, Name | findstr /I /V Element | findstr /R .';
	
	foreach my $machine (_getVirtualMachines(command => $command, logger => $logger)) {
	   	$inventory->addEntry(
            section => 'VIRTUALMACHINES', entry => $machine
        );
    }
}

sub  _getVirtualMachines {

    my $handle = getFileHandle(@_);
    return unless $handle;

    # hyperv status
    my %status_list = (
        'r' => 'running',
        'p' => 'paused',
        's' => 'shutdown',
        'u' => 'unknown',
    );

    # drop headers
    my $line  = $handle;
   	
	my @machines;
    while (my $line = <$handle>) {
        chomp $line;
        my ($name, $status, $uuid_name) = split(' ', $line);
        next if $name eq 'ElementName';
		next if $name eq $host;
        next if $uuid_name eq 'Name';
				 
		if ($status eq '2')	{ $status = 'r';}
        elsif ($status eq '3') { $status = 's';}	
        elsif ($status eq '32768') { $status = 'p';}
        else { $status = 'u';}	 	
		
		$status =~ s/-//g;
        $status = $status ? $status_list{$status} : 'off';
		
		my $UUID_ = '\'%'.$uuid_name.'%\'';
        my $command_memory = 'wmic /namespace:\\\root\\Virtualization path  Msvm_MemorySettingData WHERE "InstanceID LIKE '.$UUID_.'" get VirtualQuantity | findstr /I /V VirtualQuantity | findstr /R .'; 
		my $command_vcpu = 'wmic /namespace:\\\root\\Virtualization path  Msvm_ProcessorSettingData WHERE "InstanceID LIKE '.$UUID_.'" get VirtualQuantity | findstr /I /V VirtualQuantity | findstr /R .';  
		my $bios_guuid = 'wmic /namespace:\\\root\\Virtualization path  Msvm_VirtualSystemSettingData WHERE "SystemName LIKE '.$UUID_.'" get BIOSGUID | findstr /I /V BIOSGUID | findstr /R .';
		my $memory = `$command_memory`;
		my $vcpu = `$command_vcpu`; 
		my (@bios_guuid) = split(/{|}/,`$bios_guuid`);
		
        my $machine = {
            MEMORY    => $memory,
            NAME      => $name,
            STATUS    => $status,
            SUBSYSTEM => 'MS HyperV',
            VMTYPE    => 'HyperV',
            VCPU      => $vcpu,
            UUID      => $bios_guuid[1],
        };
        
		push @machines, $machine;
		my $line = 1;

    }
	close $handle;
    return @machines;
}

1;
