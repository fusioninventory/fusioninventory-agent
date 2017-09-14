package FusionInventory::Agent::SNMP::MibSupport;

use strict;
use warnings;

use File::Glob;

use FusionInventory::Agent::Tools;

sub new {
    my ($class, %params) = @_;

    my $logger  = $params{logger};
    my $sysorid = $params{sysorid_list};

    return unless $sysorid;

    my $self = {
        _SUPPORT    => [],
        logger      => $logger
    };

    # Load any related sub-module dedicated to MIB support
    my ($sub_modules_path) = $INC{module2file(__PACKAGE__)} =~ /(.*)\.pm/;
    my %available_mib_support = ();
    foreach my $file (File::Glob::bsd_glob("$sub_modules_path/*.pm")) {
        next unless $file =~ m{$sub_modules_path/(\S+)\.pm$};

        my $module = __PACKAGE__ . "::" . $1;
        my $supported_mibs = runFunction(
            module   => $module,
            function => "mibSupport",
            logger   => $self->{logger},
            params   => undef,
            load     => 1
        );

        if ($supported_mibs && @{$supported_mibs}) {
            foreach my $mib_support (@{$supported_mibs}) {
                my $miboid = $mib_support->{oid}
                    or next;
                $mib_support->{module} = $module;
                # Include support for related OID
                $available_mib_support{$miboid} = $mib_support;
            }
        }
    }

    # Keep in _SUPPORT only needed mib support
    foreach my $mibindex (sort keys %{$sysorid}) {
        my $miboid = $sysorid->{$mibindex};
        my $supported = $available_mib_support{$miboid}
            or next;
        my $mibname = $supported->{name}
            or next;
        $logger->debug2("$mibname mib support enabled") if $logger;
        push @{$self->{_SUPPORT}}, $supported;
    }

    bless $self, $class;

    return $self;
}

sub get {
    my ($self) = @_;

    return @{$self->{_SUPPORT}};
}

1;

__END__

=head1 NAME

FusionInventory::Agent::SNMP::MibSupport - FusionInventory agent SNMP mib support

=head1 DESCRIPTION

Class to help handle vendor-specific mibs support modules

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item logger

=item sysorid_list (mandatory)

=item device (mandatory)

=back
