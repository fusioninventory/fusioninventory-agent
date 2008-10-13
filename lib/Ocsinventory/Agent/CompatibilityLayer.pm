package Ocsinventory::Agent::CompatibilityLayer;
# This package intends to add compatibility with the old linux_agent.

use strict;
use warnings;

use FindBin qw($Bin);

sub new {
  my (undef, $params) = @_;

  my $self = {};
  $self->{accountinfo} = $params->{accountinfo};
  $self->{accountconfig} = $params->{accountconfig};
  my $logger = $self->{logger} = $params->{logger};
  $self->{params} = $params->{params};

  $self->{dontuse} = 1;

  my $modulefile;
  foreach (@{$self->{params}->{etcdir}}) {
    $modulefile = $_.'/modules.conf';
    if (-f $modulefile) {
      if (do $modulefile) {
	$self->{dontuse} = 0;
      } else {
	$logger->debug("Failed to load `$modulefile': $?. No external module will".
	  " be used.");
      }
      last;
    }
  }

  if (!$self->{dontuse}) {
      my $ocsAgentServerUri;

      # to avoid a warning if $self->{params}->{server} is not defined
      if ($self->{params}->{server}) {
          $ocsAgentServerUri = "http://".$self->{params}->{server}.$self->{params}->{remotedir};
      }

    $self->{current_context} = {
      OCS_AGENT_LOG_PATH => $self->{params}->{logdir}."modexec.log",
      OCS_AGENT_SERVER_URI => $ocsAgentServerUri,
      OCS_AGENT_INSTALL_PATH => $self->{params}->{vardir},
      OCS_AGENT_DEBUG_LEVEL => 2, # TODO
      OCS_AGENT_EXE_PATH => $Bin,
      OCS_AGENT_SERVER_NAME => $self->{params}->{server},
      OCS_AGENT_AUTH_USER => $self->{params}->{user},
      OCS_AGENT_AUTH_PWD => $self->{params}->{password},
      OCS_AGENT_AUTH_REALM => $self->{params}->{realm},
      OCS_AGENT_DEVICEID => $self->{params}->{deviceid},
      OCS_AGENT_VERSION => $self->{params}->{VERSION},
      OCS_AGENT_CMDL => "TOTO", # TODO cmd line parameter changed with the unified agent
      OCS_AGENT_CONFIG => $self->{params}->{accountconfig},
      # The prefered way to log message
      OCS_AGENT_LOGGER => $self->{logger},
    };
  }


  bless $self;

}


sub hook {
  my ($self, $args, $optparam) = @_;

  return if $self->{dontuse};
  my $name = $args->{name};

  my $logger = $self->{logger};

  $logger->debug("Calling handlers : `$name'");

  my @f = get_symbols($name);

  foreach (@f) {
    $logger->debug(" run func: `$_'");
    no strict 'refs';
    eval { &$_($self->{current_context}, $optparam); };
    if ($@) {$logger->error("$_ > exec failed: $@")}
  }

}


sub get_symbols {
  my $suffix = shift;
  my @ret;
#        for(sort keys(%main::)){
#                push @ret, \&$_ if $_=~/$suffix$/;
#        }
  no strict 'refs';
  foreach my $mod (keys %Ocsinventory::Agent::Option::) {
    foreach (@{"Ocsinventory::Agent::Option::".$mod."EXPORT"}) {
      next unless $_ =~ /$suffix$/;
      push @ret, "Ocsinventory::Agent::Option::".$mod."$_";
    }
  }

  return @ret;
}

1;
