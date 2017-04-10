package FusionInventory::Agent::HTTP::Protocol::https;

use strict;
use warnings;
use base qw(LWP::Protocol::https);

use IO::Socket::SSL qw(SSL_VERIFY_NONE SSL_VERIFY_PEER);

sub import {
    my ($class, %params) = @_;

    # set default context
    if ($params{ca_cert_path}) {
        if (-f $params{ca_cert_path}) {
            IO::Socket::SSL::set_ctx_defaults(ca_file => $params{ca_cert_path})
        } else {
            IO::Socket::SSL::set_ctx_defaults(ca_path => $params{ca_cert_path})
        }
    }
}

sub _extra_sock_opts {
    my ($self, $host) = @_;

    return (
        SSL_verify_mode     => $self->{ua}->{ssl_check} ?
                                SSL_VERIFY_PEER : SSL_VERIFY_NONE,
        SSL_verifycn_scheme => 'http',
        SSL_verifycn_name   => $host
    );
}

## no critic (ProhibitMultiplePackages)
package FusionInventory::Agent::HTTP::Protocol::https::Socket;

use base qw(Net::HTTPS LWP::Protocol::http::SocketMethods);

1;
__END__

=head1 NAME

FusionInventory::Agent::HTTP::Protocol::https - HTTPS protocol handler for LWP

=head1 DESCRIPTION

This is an overrided HTTPS protocol handler for LWP, allowing to use
subjectAltNames for checking server certificate.
