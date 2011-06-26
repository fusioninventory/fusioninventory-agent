package FusionInventory::Agent::HTTP::HTTPSHandler;

use strict;
use warnings;
use base qw(LWP::Protocol::https);

use IO::Socket::SSL;

sub _check_sock {
    my($self, $req, $sock) = @_;

    my $subject_check     = $req->header("If-SSL-Cert-Subject");
    my $alt_subject_check = $req->header("If-SSL-Cert-SubjectAltNames");

    # no check
    return if !$subject_check && !$alt_subject_check;

    my $cert = $sock->get_peer_certificate || die "Missing SSL certificate";
    my $error = '';

    # check against subject
    if (defined $subject_check) {
        my $subject = $cert->peer_certificate('subject');
        if ($subject =~ /$subject_check/) {
            # don't pass those headers
            $req->remove_header("If-SSL-Cert-Subject");
            $req->remove_header("If-SSL-Cert-subjectAltNames");
            return;
        }
        $error .= "subject '$subject' doesn't match '$subject_check'";
    }

    # check against subjectAltNames
    if ($alt_subject_check) {
        my @alt_subjects = $cert->peer_certificate('subjectAltNames');
        my @values;
        while (@alt_subjects) {
            my $type  = shift @alt_subjects;
            my $value = shift @alt_subjects;
            next unless $type == GEN_DNS;
            if ($value =~ /$alt_subject_check/) {
                $req->remove_header("If-SSL-Cert-Subject");
                $req->remove_header("If-SSL-Cert-subjectAltNames");
                return;
            } else {
                push @values, $value;
            }
        }
        $error .=
            " and no alternate subject "       .
            join(', ', map { "'$_'" } @values) .
            " match '$alt_subject_check'";
    }

    die "Bad SSL certificate: $error";
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
