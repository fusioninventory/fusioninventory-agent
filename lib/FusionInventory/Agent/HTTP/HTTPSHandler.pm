package FusionInventory::Agent::HTTP::HTTPSHandler;

use strict;
use warnings;
use base qw(LWP::Protocol::https);

use IO::Socket::SSL;

sub _extra_sock_opts {
    my ($self, $host, $port) = @_;

    return (
        SSL_verify_mode     => $self->{ua}->{ssl_check},
        SSL_verifycn_scheme => 'http',
        SSL_verifycn_name   => $host
    );
}

package FusionInventory::Agent::HTTP::HTTPSHandler::Socket;

use base qw(Net::HTTPS LWP::Protocol::http::SocketMethods);

1;
__END__

=head1 NAME

FusionInventory::Agent::HTTP::HTTPS - HTTPS protocol handler for LWP

=head1 DESCRIPTION

This is an overrided HTTPS protocol handler for LWP, allowing to use
subjectAltNames for checking server certificate.
