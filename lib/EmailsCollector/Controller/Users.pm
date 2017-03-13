package EmailsCollector::Controller::Users;
use Mojo::Base 'Mojolicious::Controller';

sub login {
  my $self = shift;
  $self->render();
}

sub logout {
  my $self = shift;
  $self->session(expires => 1)->redirect_to('login')
}

sub profile {
  my $self = shift;
  my $session = $self->session();

  $self->render(email => $session->{'email'}, name => $session->{'name'})
}

sub check_session {
  my $self = shift;

  if ($self->session()->{'email'}) {
    return 1
  }

  $self->redirect_to('login')
}

1;
