package FusionInventory::Agent::Network;
use strict;
use warnings;

=head1 NAME

FusionInventory::Agent::Network - the Network abstraction layer

=head1 DESCRIPTION

This module is the abstraction layer for network interaction. It uses LWP.
Not like LWP, it can vlaide SSL certificat with Net::SSLGlue::LWP.

=cut

=over 4

=item new()

The constructor. These keys are expected: config, logger, target.

        my $network = FusionInventory::Agent::Network->new ({
    
                logger => $logger,
                config => $config,
                target => $target,
    
            });


=cut

use FusionInventory::Compress;

sub new {
  my (undef, $params) = @_;

  my $self = {};
  
  $self->{accountinfo} = $params->{accountinfo}; # Q: Is that needed? 

  my $config = $self->{config} = $params->{config};
  my $logger = $self->{logger} = $params->{logger};
  my $target = $self->{target} = $params->{target};
  
  $logger->fault('$target not initialised') unless $target;
  $logger->fault('$config not initialised') unless $config;

  if (! eval "use LWP::UserAgent; 1;") {
    $logger->fault("Can't load LWP::UserAgent. Is the package installed?");
  }
  if (! eval "use HTTP::Status; 1;") {
    $logger->fault("Can't load HTTP::Status. Is the package installed?");
  }


  my $uaserver;
  if ($target->{path} =~ /^http(|s):\/\//) {
      $uaserver = $self->{URI} = $target->{path};
      $uaserver =~ s/^http(|s):\/\///;
      $uaserver =~ s/\/.*//;
      if ($uaserver !~ /:\d+$/) {
          $uaserver .= ':443' if $self->{config}->{server} =~ /^https:/;
          $uaserver .= ':80' if $self->{config}->{server} =~ /^http:/;
      }
  } else {
    $logger->fault("Failed to parse URI: ".$target->{path});
  }


  $self->{compress} = new FusionInventory::Compress ({logger => $logger});
  # Connect to server
  $self->{ua} = LWP::UserAgent->new(keep_alive => 1);
  if ($self->{config}->{proxy}) {
    $self->{ua}->proxy(['http', 'https'], $self->{config}->{proxy});
  }  else {
    $self->{ua}->env_proxy;
  }
  my $version = 'FusionInventory-Agent_v'.$config->{VERSION};
  $self->{ua}->agent($version);
  $self->{ua}->credentials(
    $uaserver, # server:port, port is needed 
    $self->{config}->{realm},
    $self->{config}->{user},
    $self->{config}->{password}
  );

  bless $self;
  return $self;
}

=item send()

Send an instance of FusionInventory::Agent::XML::Query::* to the target (the
server).

=cut


sub send {
  my ($self, $args) = @_;

  my $logger = $self->{logger};
  my $target = $self->{target};
  my $config = $self->{config};
  
  my $compress = $self->{compress};
  my $message = $args->{message};
  my ($msgtype) = ref($message) =~ /::(\w+)$/; # Inventory or Prolog

  $self->setSslRemoteHost({ url => $self->{URI} });

  my $req = HTTP::Request->new(POST => $self->{URI});

  $req->header('Pragma' => 'no-cache', 'Content-type',
    'application/x-compress');


  $logger->debug ("sending XML");

  # Print the XMLs in the debug output
  #$logger->debug ("sending: ".$message->getContent());

  my $compressed = $compress->compress( $message->getContent() );

  if (!$compressed) {
    $logger->error ('failed to compress data');
    return;
  }

  $req->content($compressed);

  my $res = $self->{ua}->request($req);

  # Checking if connected
  if(!$res->is_success) {
    $logger->error ('Cannot establish communication with `'.
        $self->{URI}.': '.
        $res->status_line.'`');
    return;
  }

  # stop or send in the http's body

  my $content = '';

  if ($res->content) {
    $content = $compress->uncompress($res->content);
    if (!$content) {
        $logger->error ("Deflating problem");
        return;
    }
  }

  # AutoLoad the proper response object
  my $msgType = ref($message); # The package name of the message object
  my $tmp = "FusionInventory::Agent::XML::Response::".$msgtype;
  eval "require $tmp";
  if ($@) {
      $logger->error ("Can't load response module $tmp: $@");
  }
  $tmp->import();
  my $response = $tmp->new ({

     accountinfo => $target->{accountinfo},
     content => $content,
     logger => $logger,
     origmsg => $message,
     target => $target,
     config => $self->{config}

      });

  return $response;
}

# No POD documentation here, it's an internal fuction
# http://stackoverflow.com/questions/74358/validate-server-certificate-with-lwp
sub turnSSLCheckOn {
  my ($self, $args) = @_;

  my $logger = $self->{logger};
  my $config = $self->{config};


  if ($config->{noSslCheck}) {
    if (!$config->{SslCheckWarningShown}) {
      $logger->info( "--no-ssl-check parameter "
        . "found. Don't check server identity!!!" );
      $config->{SslCheckWarningShown} = 1;
    }
    return;
  }

  my $hasCrypSSLeay;
  my $hasIOSocketSSL;

  eval 'use Crypt::SSLeay;';
  my $hasCrypSSLeay = ($@)?0:1;

  if (!$hasCrypSSLeay) {
      eval 'use IO::Socket::SSL;';
      $hasIOSocketSSL = ($@)?0:1;
  }

  if (!$hasCrypSSLeay && !$hasIOSocketSSL) {
    $logger->fault(
      "Failed to load Crypt::SSLeay or IO::Socket::SSL, to ".
         "validate the server SSL cert. If you want ".
         "to ignore this message and want to ignore SSL ".
         "verification, you can use the ".
         "--no-ssl-check parameter to disable SSL check."
    );
  }
  if (!$config->{caCertFile} && !$config->{caCertDir}) {
      $logger->fault("You need to use either --ca-cert-file ".
          "or --ca-cert-dir to give the location of your SSL ".
          "certificat. You can also disable SSL check with ".
          "--no-ssl-check but this is very unsecure.");
  }


  my $parameter;
  if ($config->{caCertFile}) {
    if (!-f $config->{caCertFile} || !-l $config->{caCertFile}) {
        $logger->fault("--ca-cert-file doesn't existe ".
            "`".$config->{caCertFile}."'");
    }

    $ENV{HTTPS_CA_FILE} = $config->{caCertFile};

    if (!$hasCrypSSLeay && $hasIOSocketSSL) {
      eval {
        IO::Socket::SSL::set_ctx_defaults(
          verify_mode => Net::SSLeay->VERIFY_PEER(),
          ca_file => $config->{caCertFile}
        );
      };
      $logger->fault(
                     "Failed to set ca-cert-file: $@".
                     "Your IO::Socket::SSL distribution is too old. ".
                     "Please install Crypt::SSLeay or disable ".
                     "SSL server check with --no-ssl-check"
		    ) if $@;
    }

  } elsif ($config->{caCertDir}) {
    if (!-d $config->{caCertDir}) {
        $logger->fault("--ca-cert-dir doesn't existe ".
            "`".$config->{caCertDir}."'");
    }

    $ENV{HTTPS_CA_DIR} =$config->{caCertDir};
    if (!$hasCrypSSLeay && $hasIOSocketSSL) {
      eval {
        IO::Socket::SSL::set_ctx_defaults(
          verify_mode => Net::SSLeay->VERIFY_PEER(),
          ca_path => $config->{caCertDir}
        );
      };
      $logger->fault(
                     "Failed to set ca-cert-file: $@".
                     "Your IO::Socket::SSL distribution is too old. ".
                     "Please install Crypt::SSLeay or disable ".
                     "SSL server check with --no-ssl-check"
		    ) if $@;
    }
  }

} 

sub setSslRemoteHost {
  my ($self, $args) = @_;

  my $uri = $self->{URI};

  my $config = $self->{config};
  my $logger = $self->{logger};

  my $ua = $self->{ua};

  if ($config->{noSslCheck}) {
      return;
  }

  if (!$self->{URI}) {
    $logger->fault("setSslRemoteHost(), no url parameter!");
  }

  if ($self->{URI} !~ /^https:/i) {
      return;
  }
  $self->turnSSLCheckOn();

  # Check server name against provided SSL certificate
  if ( $self->{URI} =~ /^https:\/\/([^\/]+).*$/i ) {
      my $cn = $1;
      $cn =~ s/([\-\.])/\\$1/g;
      $ua->default_header('If-SSL-Cert-Subject' => '/CN='.$cn);
  }
}


=item getStore()

Acts like LWP::Simple::getstore.

        my $rc = $network->getStore({
                source => 'http://www.FusionInventory.org/',
                target => '/tmp/fusioinventory.html'
            });

$rc, can be read by isSuccess()

=cut
sub getStore {
  my ($self, $args) = @_;

  my $source = $args->{source};
  my $target = $args->{target};
  my $timeout = $args->{timeout};
  
  my $ua = $self->{ua};

  $self->setSslRemoteHost({ url => $source });
  $ua->timeout($timeout) if $timeout;

  my $request = HTTP::Request->new(GET => $source);
  my $response = $ua->request($request, $target);

  return $response->code;

}

=item get()

        my $content = $network->get({
                source => 'http://www.FusionInventory.org/',
                timeout => 15
            });

Act like LWP::Simple::get, return the HTTP content of the URL in 'source'.
The timeout is optional

=cut
sub get {
  my ($self, $args) = @_;

  my $source = $args->{source};
  my $timeout = $args->{timeout};

  my $ua = $self->{ua};

  $self->setSslRemoteHost({ url => $source });
  $ua->timeout($timeout) if $timeout;

  my $response = $ua->get($source);

  return $response->decoded_content if $response->is_success;

  return undef;

}

=item isSuccess()

Wrapper for LWP::is_success;

        die unless $network->isSuccess({ code => $rc });
=cut

sub isSuccess {
  my ($self, $args) = @_;

  my $code = $args->{code};

  return is_success($code);

}

1;
