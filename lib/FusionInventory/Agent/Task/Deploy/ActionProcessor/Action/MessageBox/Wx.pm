use strict;
use Wx;

package MyInfoFrame;

use utf8;
use Wx qw(:everything);
use Wx::Event qw( EVT_BUTTON EVT_TIMER );
use base qw/Wx::Frame/;

sub new
{
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{ret} = "unknown";
    $self->{maxTime} = undef;

    my $panel = Wx::Panel->new( $self,
            -1
            );

    $self->{txt} = Wx::TextCtrl->new( $panel,
            1,
            "",
            [5, 5],
            [250, 120],
            (wxTE_MULTILINE|wxTE_READONLY|wxTE_BESTWRAP)
            );

    my $BTNPPID = 1;
    my $BTNOKID = 1;

    $self->{pp} = Wx::Button->new(     $panel,
            $BTNPPID,
            "Later",
            [100,130]
            );
    $self->{pp}->Hide();

    $self->{btn} = Wx::Button->new(     $panel,
            $BTNOKID,
            "OK",
            [200,130]
            );


    EVT_BUTTON( $self,
            $BTNPPID,
            \&ButtonPPClicked
            );

    EVT_BUTTON( $self,
            $BTNOKID,
            \&ButtonOKClicked
            );


    return $self;
}

sub setMsg {
    my( $self, $msg ) = @_;

    $self->{txt}->SetLabel($msg);

}

sub setTimer {
    my( $self, $timer ) = @_;

    return unless $timer;

    $self->{hTimer} = Wx::Timer->new($self);
    $self->{hTimer}->Start(100);
    
    $self->{maxTime} = time + $timer;

    EVT_TIMER($self, -1, \&OnTimer);

}

sub OnTimer {
    my( $self, $event ) = @_;

    my $string = "OK";
    if ($self->{maxTime}) {
        $string .= "  (".int($self->{maxTime}-time).")"
    }
    $self->{btn}->SetLabel($string);
    
    if ($self->{maxTime} && (time > $self->{maxTime})) {
        $self->{ret} = "timeout";
        $self->{hTimer}->Stop;
        $self->Hide();
        Wx::wxTheApp->ExitMainLoop;
    }
}

sub ButtonPPClicked
{
    my( $self, $event ) = @_;

    $self->{ret} = "pp";
    $self->Hide();
    Wx::wxTheApp->ExitMainLoop;
}


sub ButtonOKClicked
{
    my( $self, $event ) = @_;

    $self->Hide();
    $self->{ret} = "ok";
    Wx::wxTheApp->ExitMainLoop;
}

1;
package MessageBox;

use utf8;
use base qw(Wx::App);

sub OnInit
{
    1
}

sub createInfo
{
    my ($self, $params) = @_;

    my $frame = MyInfoFrame->new(   undef,
            -1,
            $params->{title},
            [10,10],
            [300, 200]
            );

    $frame->setTimer($params->{timeout});
    $frame->setMsg($params->{msg});

    $self->SetTopWindow($frame);
    $self->{frame}=$frame;
    $frame->Show(1);
}

sub createPostpone
{
    my ($self, $params) = @_;

    my $frame = MyInfoFrame->new(   undef,
            -1,
            $params->{title},
            [10,10],
            [300, 200]
            );

    $frame->setTimer($params->{timeout});
    $frame->setMsg($params->{msg});

    $self->SetTopWindow($frame);
    $self->{frame}=$frame;
    $frame->{pp}->Show();
    $frame->Show(1);
}

1;

package FusionInventory::Agent::Task::Deploy::ActionProcessor::Action::MessageBox::Wx;

use strict;
use warnings;
use base 'Exporter';
use Data::Dumper;

our @EXPORT = qw(
    createInfoBox
    createPostponeBox
);


our $wxobj = MessageBox->new(undef);
sub createInfoBox {
    $wxobj->createInfo(@_);

    $wxobj->MainLoop;
    use Data::Dumper;
    return $wxobj->{frame}{ret};
}

sub createPostponeBox {
    $wxobj->createPostpone(@_);

    $wxobj->MainLoop;
print Dumper($wxobj->{frame});
    return $wxobj->{frame}{ret};
}


1;


=head1 wxPerl wrapper 


=item createInfoBox({ timeout => 60, title => "My Info title", "msg" => "This is a message." });

=item createPostponeBox({ timeout => undef, title => "My Info title", "msg" => "This is a message." });
