package FusionInventory::Agent::Job::Network;

use strict;
use warnings;

use POE::Component::IKC::ClientLite;
my $poe;

sub new {
    my $self = {};

    my $name   = "Network$$";
    $poe = create_ikc_client(
        port    => 3030,
        name    => $name,
        timeout => 10,
    );
    die $POE::Component::IKC::ClientLite::error unless $poe;

    bless $self;
}

sub send {
    my ($self, $args) = @_;

    my $message = $args->{message};
    
    my ($msgType) = ref($message) =~ /::(\w+)$/; # Inventory or Prolog
   
   print "=BEGIN MSG($msgType)=\n";
   my $xmlContent = $message->getContent();
#   print $content."\n";
    $poe->post_respond('network/send', { xmlContent => $xmlContent, msgType => $msgType });
   print "=END MSG=\n";
}


1;
