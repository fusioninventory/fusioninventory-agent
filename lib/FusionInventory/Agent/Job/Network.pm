package FusionInventory::Agent::Job::Network;

sub new {
    my $self = {};
    
    bless $self;
}

sub send {
    my ($self, $args) = @_;

    my $message = $args->{message};
    
    my ($msgtype) = ref($message) =~ /::(\w+)$/; # Inventory or Prolog
   
   print STDOUT "=BEGIN PERLMSG=\n"; 
   print $message->getContent();
   print STDOUT "=END PERLMSG=\n"; 
}

1;
