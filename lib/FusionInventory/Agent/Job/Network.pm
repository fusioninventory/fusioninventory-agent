package FusionInventory::Agent::Job::Network;

sub new {
    my $self = {};
    
    bless $self;
}

sub send {
    my ($self, $args) = @_;

    my $message = $args->{message};
    
    my ($msgtype) = ref($message) =~ /::(\w+)$/; # Inventory or Prolog
   
   print STDOUT "=BEGIN MSG($msgtype)=\n";
   print STDOUT $message->getContent()."\n";
   print STDOUT "=END MSG=\n";
}

1;
