package FusionInventory::Agent::HTTP::Client::ArmaditoAV;

use strict;
use warnings;
use base 'FusionInventory::Agent::HTTP::Client';

use English qw(-no_match_vars);
use HTTP::Request;
use HTTP::Request::Common qw( POST );
use UNIVERSAL::require;
use URI;
use Encode;
use Data::Dumper;
use URI::Escape;
use JSON;

use FusionInventory::Agent::HTTP::Client::ArmaditoAV::Event;
use FusionInventory::Agent::HTTP::Client::ArmaditoAV::Event::StatusEvent;

my @supported_events = ( "StatusEvent" );

sub new {
	my ( $class, %params ) = @_;
	my $self = $class->SUPER::new(%params);

	$self->{server_url} = "http://localhost:8888";

	return $self;
}

sub _prepareURL {
	my ( $self, %params ) = @_;

	my $url = ref $params{url} eq 'URI' ? $params{url} : URI->new( $params{url} );

	return $url;
}

sub sendRequest {
	my ( $self, %params ) = @_;

	my $url = $self->_prepareURL(%params);

	$self->{logger}->debug2($url) if $self->{logger};

	my $headers = HTTP::Headers->new(
		'User-Agent' => 'fusioninventory-agent',
		'Referer'    => $url
	);

	$headers->header( 'Content-Type'     => 'application/json' ) if ( $params{method} eq 'POST' );
	$headers->header( 'X-Armadito-Token' => $self->{token} )     if ( defined( $self->{token} ) );

	my $request = HTTP::Request->new(
		$params{method} => $url,
		$headers
	);

	if ( $params{message} && $params{method} eq 'POST' ) {
		$request->content( encode( 'UTF-8', $params{message} ) );
	}

	return $self->request($request);
}

sub _handleRegisterResponse() {
	my ( $self, $response ) = @_;

	my $obj = from_json( $response->content(), { utf8 => 1 } );

	if ( defined( $obj->{token} ) ) {
		$self->{token} = $obj->{token};
		$self->{logger}->debug( "ArmaditoAV Registration successful, session token : " . $obj->{token} );
	}
	else {
		$self->{logger}->error("Invalid token from ArmaditoAV registration.");
	}
}

sub register {
	my ($self) = @_;

	my $response = $self->sendRequest(
		"url"  => $self->{server_url} . "/api/register",
		method => "GET"
	);

	die "Unable to register to ArmaditoAV api." if ( !$response->is_success() || !$response->content() =~ /^\s*\{/ms );
	$self->_handleRegisterResponse($response);
	return $self;
}

sub unregister {
	my ($self) = @_;

	my $response = $self->sendRequest(
		"url"  => $self->{server_url} . "/api/unregister",
		method => "GET"
	);

	die "Unable to unregister to ArmaditoAV api." if ( !$response->is_success() );
	return $self;
}

sub _handleJsonResponse() {
	my ( $self, $response ) = @_;

	$self->{logger}->debug( $response->content() );

	return from_json( $response->content(), { utf8 => 1 } );
}

sub pollEvents {
	my ($self) = @_;
	my $event = {};
	
	while (1) {
		my $jobj = $self->_getEvent();
		if ( defined( $jobj->{"event_type"} ) ) {
			$event = $self->_handleEvent($jobj);
			last if($event->{end_polling});
		}
	}

	return $event;
}

sub _getEvent {
	my ($self) = @_;

	my $response = $self->sendRequest(
		"url"  => $self->{server_url} . "/api/event",
		method => "GET"
	);

	die "Unable to get event with ArmaditoAV api."
		if ( !$response->is_success() || !$response->content() =~ /^\s*\{/ms );
	return $self->_handleJsonResponse($response);
}

sub getAntivirusVersion {
	my ($self) = @_;

	my $response = $self->sendRequest(
		"url"  => $self->{server_url} . "/api/version",
		method => "GET"
	);

	die "Unable to get Armadito version with ArmaditoAV api."
		if ( !$response->is_success() || !$response->content() =~ /^\s*\{/ms );
	return $self->_handleJsonResponse($response);
}

sub _isEventSupported {
	my ( $self, $event ) = @_;
	foreach (@supported_events) {
		if ( $event eq $_ ) {
			return 1;
		}
	}
	return 0;
}

sub _handleEvent {
	my ( $self, $event_jobj) = @_;

	if ( !$self->_isEventSupported( $event_jobj->{"event_type"} ) ) {
		$self->{logger}->error("Unknown ArmaditoAV api event.");
		return 0;
	}

	my $class = "FusionInventory::Agent::HTTP::Client::ArmaditoAV::Event::$event_jobj->{'event_type'}";
	$class->require();
	my $event = $class->new( jobj => $event_jobj );
	return $event->run();
}

1;
__END__

=head1 NAME

FusionInventory::Agent::HTTP::Client::ArmaditoAV - HTTP Client for armadito AV RESTful API.

=head1 DESCRIPTION

This is the class used by FusionInventory agent to communicate with armadito antivirus locally.

=head1 METHODS

=head2 $client->register()

Register to Armadito Antivirus API And set token after parsing AV json response.

=head2 $client->sendRequest(%params)

Send a request according to params given. If this is a GET request, params are formatted into URL with _prepareURL method. If this is a POST request, a message must be given in params. This should be a valid JSON message.

The following parameters are allowed, as keys of the %params hash :

=over

=item I<url>

the url to send the message to (mandatory)

=item I<method>

the method used: GET or POST. (mandatory)

=item I<message>

the message to send (mandatory if method is POST)

=back

The return value is a response object. See L<HTTP::Request> and L<HTTP::Response> for a description of the interface provided by these classes.
