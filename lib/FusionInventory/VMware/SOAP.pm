package FusionInventory::VMware::SOAP;

use strict;
use warnings;

use XML::TreePP;
use LWP::UserAgent;
use HTTP::Cookies; #for testing

sub new {
    my (undef, $params) = @_;

    my $self = {
        ua => LWP::UserAgent->new(),
        url => $params->{url}
    };
    my $cookie = new HTTP::Cookies( ignore_discard => 1 );
    $self->{ua}->cookie_jar( $cookie );

    push @{ $self->{ua}->requests_redirectable }, 'POST';
    $self->{ua}->agent("VMware::PoorBoySOAP/0.1 ");

    $self->{tpp} = XML::TreePP->new(force_array => [qw( returnval propSet )]);
    return bless $self;
}

sub _send {
    my ($self, $action, $xmlToSend) = @_;


    my $req = HTTP::Request->new(POST => $self->{url});
    $req->content($xmlToSend);
    $req->{_headers}->{soapaction} = "\"urn:vim25#".$action."\"";
    $req->{_headers}->{accept} = ['text/xml', 'application/soap' ];
    $req->{_headers}->{'content-length'} = length($xmlToSend);
    $req->{_protocol} = 'HTTP/1.1';
    $req->content_type('text/xml; charset=utf-8');

    my $res = $self->{ua}->request($req);

    if ($res->is_success) {
        return $res->content;
    } else {
        return;
    }
}

sub _parseAnswer {
    my ($self, $answer) = @_;

    return unless $answer;
    undef $/;

# We simplify the XML structure
    my $pattern = '.*<\w+Response xmlns="urn:vim25">(.+)</\w+Response>.*$';
    $answer =~ s/$pattern/$1/sg,;
    $answer =~ s/ (xsi:|)type="[:\w]+"//sg;
    my $tmpRef = $self->{tpp}->parse($answer);

# Login
    if ($tmpRef->{returnval}[0] && !$tmpRef->{returnval}[0]{propSet}) {
        return $tmpRef->{returnval}[0];
    }
# Else the rest

    my $ref = [];
    foreach (@{$tmpRef->{returnval}}) {
        if ($_->{propSet}) {
            my %tmp;
            foreach my $p (@{$_->{propSet}}) {
                next unless $p->{val};
                $tmp{$p->{name}} = $p->{val}
            }
            push @$ref, \%tmp;
        } else {
            push @$ref, $_;
        }
    }

    return $ref;

}

sub login {
    my ($self, $login, $pw) = @_;

    my $req =
        '<?xml version="1.0" encoding="UTF-8"?>
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <soapenv:Body>
        <Login xmlns="urn:vim25"><_this type="SessionManager">ha-sessionmgr</_this>
        <userName>%s</userName><password>%s</password></Login></soapenv:Body></soapenv:Envelope>';

    my $answer = $self->_send('Login', sprintf($req, $login, $pw));
    return $self->_parseAnswer($answer);

}

sub getHostInfo {
    my ($self) = @_;


    my $req =
        '<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><RetrieveServiceContent xmlns="urn:vim25"><_this type="ServiceInstance">ServiceInstance</_this></RetrieveServiceContent></soap:Body></soap:Envelope>';


    my $answer = $self->_send('RetrieveServiceContent', $req);
    my $ref = $self->_parseAnswer($answer);
    return $ref;
}


sub getVirtualMachineList {
    my ($self) = @_;

    my $req =

        '<?xml version="1.0" encoding="UTF-8"?>
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <soapenv:Body>
        <RetrieveProperties xmlns="urn:vim25"><_this type="PropertyCollector">ha-property-collector</_this>
        <specSet><propSet><type>VirtualMachine</type><all>0</all></propSet><objectSet><obj type="Folder">ha-folder-root</obj>
        <skip>0</skip><selectSet xsi:type="TraversalSpec"><name>folderTraversalSpec</name><type>Folder</type><path>childEntity</path><skip>0</skip><selectSet><name>folderTraversalSpec</name></selectSet><selectSet><name>datacenterHostTraversalSpec</name></selectSet><selectSet><name>datacenterVmTraversalSpec</name></selectSet><selectSet><name>datacenterDatastoreTraversalSpec</name></selectSet><selectSet><name>datacenterNetworkTraversalSpec</name></selectSet><selectSet><name>computeResourceRpTraversalSpec</name></selectSet><selectSet><name>computeResourceHostTraversalSpec</name></selectSet><selectSet><name>hostVmTraversalSpec</name></selectSet><selectSet><name>resourcePoolVmTraversalSpec</name></selectSet></selectSet><selectSet xsi:type="TraversalSpec"><name>datacenterDatastoreTraversalSpec</name><type>Datacenter</type><path>datastoreFolder</path><skip>0</skip><selectSet><name>folderTraversalSpec</name></selectSet></selectSet><selectSet xsi:type="TraversalSpec"><name>datacenterNetworkTraversalSpec</name><type>Datacenter</type><path>networkFolder</path><skip>0</skip><selectSet><name>folderTraversalSpec</name></selectSet></selectSet><selectSet xsi:type="TraversalSpec"><name>datacenterVmTraversalSpec</name><type>Datacenter</type><path>vmFolder</path><skip>0</skip><selectSet><name>folderTraversalSpec</name></selectSet></selectSet><selectSet xsi:type="TraversalSpec"><name>datacenterHostTraversalSpec</name><type>Datacenter</type><path>hostFolder</path><skip>0</skip><selectSet><name>folderTraversalSpec</name></selectSet></selectSet><selectSet xsi:type="TraversalSpec"><name>computeResourceHostTraversalSpec</name><type>ComputeResource</type><path>host</path><skip>0</skip></selectSet><selectSet xsi:type="TraversalSpec"><name>computeResourceRpTraversalSpec</name><type>ComputeResource</type><path>resourcePool</path><skip>0</skip><selectSet><name>resourcePoolTraversalSpec</name></selectSet><selectSet><name>resourcePoolVmTraversalSpec</name></selectSet></selectSet><selectSet xsi:type="TraversalSpec"><name>resourcePoolTraversalSpec</name><type>ResourcePool</type><path>resourcePool</path><skip>0</skip><selectSet><name>resourcePoolTraversalSpec</name></selectSet><selectSet><name>resourcePoolVmTraversalSpec</name></selectSet></selectSet><selectSet xsi:type="TraversalSpec"><name>hostVmTraversalSpec</name><type>HostSystem</type><path>vm</path><skip>0</skip><selectSet><name>folderTraversalSpec</name></selectSet></selectSet><selectSet xsi:type="TraversalSpec"><name>resourcePoolVmTraversalSpec</name><type>ResourcePool</type><path>vm</path><skip>0</skip></selectSet></objectSet></specSet></RetrieveProperties></soapenv:Body></soapenv:Envelope>
        ';


    my $answer = $self->_send('RetrieveProperties', $req);
    my $ref = $self->_parseAnswer($answer);
    my @list;
    if (ref($ref) eq 'HASH') {
        push @list, $ref;
    } else {
        @list = @{$ref};
    }

    my @ids;
    foreach (@list) {
        push @ids, $_->{obj};
    }

    return \@ids;

}

sub getVirtualMachineById {
    my ($self, $id) = @_;

    my $req = '<?xml version="1.0" encoding="UTF-8"?>
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <soapenv:Body>
        <RetrieveProperties xmlns="urn:vim25"><_this type="PropertyCollector">ha-property-collector</_this>
        <specSet><propSet><type>VirtualMachine</type><all>1</all></propSet><objectSet><obj type="VirtualMachine">%d</obj>
        </objectSet></specSet></RetrieveProperties></soapenv:Body></soapenv:Envelope>
        ';

    my $answer = $self->_send('RetrieveProperties', sprintf($req, $id));
    my $ref = $self->_parseAnswer($answer);

    return $ref;
}

sub getHostFullInfo {
    my ($self, $id) = @_;

    my $req = '<?xml version="1.0" encoding="UTF-8"?>
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <soapenv:Body>
        <RetrieveProperties xmlns="urn:vim25"><_this type="PropertyCollector">ha-property-collector</_this>
        <specSet><propSet><type>HostSystem</type><all>1</all></propSet><objectSet><obj type="HostSystem">ha-host</obj>
        </objectSet></specSet></RetrieveProperties></soapenv:Body></soapenv:Envelope>
        ';

    my $answer = $self->_send('RetrieveProperties', sprintf($req, $id));
    my $ref = $self->_parseAnswer($answer);

    return $ref;
}


1;


