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
    
    my ($msgtype) = ref($message) =~ /::(\w+)$/; # Inventory or Prolog
   
   print "=BEGIN MSG($msgtype)=\n";
   my $content = $message->getContent();
   print $content."\n";
    $poe->post_respond('network/send', $content);
   print "=END MSG=\n";
}


1;
