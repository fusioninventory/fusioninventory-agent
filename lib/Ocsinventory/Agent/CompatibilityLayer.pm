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
  $self->{config} = $params->{config};

  $self->{dontuse} = 1;

  my $modulefile;
  foreach (@{$self->{config}->{etcdir}}) {
    $modulefile = $_.'/modules.conf';
    if (-f $modulefile) {
      if (do $modulefile) {
	$logger->debug("Turns CompatibilityLayer on for $modulefile");
	$self->{dontuse} = 0;
        last;
      } else {
          $logger->debug("Failed to load `$modulefile': $?");
      }
    }
  }

  if ($self->{dontuse}) {
      $logger->debug("No legacy module will be used.");
  } else {
      my $ocsAgentServerUri;

      # to avoid a warning if $self->{config}->{server} is not defined
      if ($self->{config}->{server}) {
          $ocsAgentServerUri = "http://".$self->{config}->{server}.$self->{config}->{remotedir};
      }

      if ($self->{config}->{debug}) {
        $::debug = 2;
      }

    $self->{current_context} = {
      OCS_AGENT_LOG_PATH => $self->{config}->{logdir}."modexec.log",
      OCS_AGENT_SERVER_URI => $ocsAgentServerUri,
      OCS_AGENT_INSTALL_PATH => $self->{config}->{vardir},
      OCS_AGENT_DEBUG_LEVEL => $::debug,
      OCS_AGENT_EXE_PATH => $Bin,
      OCS_AGENT_SERVER_NAME => $self->{config}->{server},
      OCS_AGENT_AUTH_USER => $self->{config}->{user},
      OCS_AGENT_AUTH_PWD => $self->{config}->{password},
      OCS_AGENT_AUTH_REALM => $self->{config}->{realm},
      OCS_AGENT_DEVICEID => $self->{config}->{deviceid},
      OCS_AGENT_VERSION => $self->{config}->{VERSION},
      OCS_AGENT_CMDL => "TOTO", # TODO cmd line parameter changed with the unified agent
      OCS_AGENT_CONFIG => $self->{config}->{accountconfig},
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
