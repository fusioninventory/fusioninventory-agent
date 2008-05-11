package Ocsinventory::Agent::Backend::OS::MacOS::Printers;
use strict;

use Mac::SysProfile;
use constant DATATYPE => 'SPPrintersDataType';

sub check {
    return(undef) unless -r '/usr/sbin/system_profiler';
    return 1;
}

sub run {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $pro = Mac::SysProfile->new();
    my $h = $pro->gettype(DATATYPE());
    return(undef) unless(ref($h) eq 'HASH');

    foreach my $printer (keys %$h){
        $inventory->setPrinters({
                NAME    => $printer,
                DRIVER  => $h->{$printer}->{'PPD'},
        });
    }

}
1;
