package EmailsCollector::Controller::Sendmail;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::JWT;

use Email::Sender::Simple 'try_to_sendmail';
use Email::Sender::Transport::SMTP::TLS;
use Email::Simple::Creator;

sub _getTransport {
  my $self = shift;

  return $self->{_transport} ||= Email::Sender::Transport::SMTP::TLS->new(
    %{ $self->app->plugin('Config')->{email}{transport} }
  );
}

sub authenticate {
  my $self = shift;

  my $name = $self->param('name');
  my $email = $self->param('email');

  if (!$name or !$email) {
    return $self->render('sendmail/error');
  }

  if ($self->_send_email($email, $name)) {
    return $self->render('sendmail/done');
  }

  $self->render('sendmail/error');
}

sub callback {
  my $self = shift;

  my $jwt = $self->param('jwt');
  my $params = $self->_jwt->decode($jwt);

  my $name = $params->{name};
  my $email = $params->{email};

  if ($name and $email) {
    $self->session(email => $email, name => $name)->redirect_to('/');
  } else {
    $self->render('sendmail/error');
  }

}

sub _jwt {
  return Mojo::JWT->new(secret => shift->app->secrets->[0]);
}

sub _send_email {
  my ($self, $email, $name) = @_;
  my $config = $self->app->plugin('Config');

  my $jwt = $self->_jwt->claims({name => $name, email => $email})->encode;
  my $url = $self->url_for($config->{base_url} . '/auth/sendmail/callback')->to_abs->query(jwt => $jwt);

  my $message = Email::Simple->create(
    header => [
      From    => $config->{email}{message}{from},
      To      => $self->param('email'),
      Subject => 'Confirm your email',
    ],
    body => "Follow this link: $url",
  );

  return try_to_sendmail($message, { transport => $self->_getTransport() });
}

1;
