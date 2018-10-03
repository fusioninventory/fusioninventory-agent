package FusionInventory::Agent::Tools::Win32::LoadIndirectString;

use warnings;
use strict;

use parent 'Exporter';

use FusionInventory::Agent::Tools::Win32::API;
use FusionInventory::Agent::Tools::Win32::WideChar;

our @EXPORT = qw(
    SHLoadIndirectString
);

my $apiSHLoadIndirectString;

sub SHLoadIndirectString {
    my ($string) = @_;

    return unless $string;

    my $wstring = MultiByteToWideChar($string)
        or return;

    unless ($apiSHLoadIndirectString) {
        $apiSHLoadIndirectString = FusionInventory::Agent::Tools::Win32::API->new(
            win32api => [
                'shlwapi',
                'SHLoadIndirectString',
                [ 'P', 'P', 'I', 'I' ],
                'N'
            ]
        );
    }

    return unless $apiSHLoadIndirectString;

    # Buffer size should be sufficient for our purpose
    my $buffer = '\0' x 4096;
    my $ret = $apiSHLoadIndirectString->Call(
        $wstring,
        $buffer,
        4096,
        0
    );

    return if ($ret || !$buffer);

    $buffer = WideCharToMultiByte($buffer);

    # api returns the same string in buffer is no indirect string was found
    return unless ($buffer && $buffer ne $string);

    return $buffer ;
}

1;
