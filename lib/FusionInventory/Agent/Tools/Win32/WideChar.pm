package FusionInventory::Agent::Tools::Win32::WideChar;

use warnings;
use strict;

use parent 'Exporter';

use Encode qw(encode decode);

use FusionInventory::Agent::Tools::Win32::API;

# UTF-8 code page
use constant CP_UTF8 => 65001;

our @EXPORT = qw(
    MultiByteToWideChar
    WideCharToMultiByte
);

my $apiMultiByteToWideChar;
my $apiWideCharToMultiByte;

sub MultiByteToWideChar {
    my ($string) = @_;

    return unless $string;

    unless ($apiMultiByteToWideChar) {
        $apiMultiByteToWideChar = FusionInventory::Agent::Tools::Win32::API->new(
            win32api => [
                'kernel32',
                'MultiByteToWideChar',
                [ 'I', 'I', 'P', 'I', 'P', 'I' ],
                'I'
            ]
        );
    }

    return unless $apiMultiByteToWideChar;

    # Encode string as UTF-8 before conversion
    $string = encode('UTF-8', $string);

    my $len    = length($string);
    my $lenbuf = 2 * $len;
    my $buffer = "\0" x $lenbuf;

    my $ret = $apiMultiByteToWideChar->Call(
        CP_UTF8, 0, $string, $len, $buffer, $lenbuf
    );
    return unless $ret;
    return $buffer;
}

sub WideCharToMultiByte {
    my ($string) = @_;

    return unless $string;

    unless ($apiWideCharToMultiByte) {
        $apiWideCharToMultiByte = FusionInventory::Agent::Tools::Win32::API->new(
            win32api => [
                'kernel32',
                'WideCharToMultiByte',
                [ 'I', 'I', 'P', 'I', 'P', 'I', 'P', 'P' ],
                'I'
            ]
        );
    }

    return unless $apiWideCharToMultiByte;

    my $lpDefaultChar = 0;
    my $lpUsedDefaultChar = 0;
    my $len = length($string);
    my $buffer = "\0" x $len;

    my $ret = $apiWideCharToMultiByte->Call(
        CP_UTF8, 0, $string, -1, $buffer, $len,
        $lpDefaultChar, $lpUsedDefaultChar
    );
    return unless $ret;

    # Cleanup buffer
    $buffer =~ s/\0+$//;

    return decode('UTF-8', $buffer);
}

1;
