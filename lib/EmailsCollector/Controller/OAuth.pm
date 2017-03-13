package EmailsCollector::Controller::OAuth;
use Mojo::Base 'Mojolicious::Controller';

sub google {
  my ( $self, $access_token, $userinfo ) = @_;
  
  my $name = $userinfo->{displayName};
  my ($email) = grep {$_->{type} eq 'account'} @{ $userinfo->{emails} };

  $self->session(email => $email->{value}, name => $name);
  $self->redirect_to('/');
}

sub github {
  my ( $self, $access_token, $userinfo ) = @_;
  $self->session(email => $userinfo->{email}, name => $userinfo->{name});
  $self->redirect_to('/');
}

sub facebook {
  my ( $self, $access_token, $userinfo ) = @_;
  
  my $ua  = Mojo::UserAgent->new;
  my $res = $ua->get("https://graph.facebook.com/me?fields=name,email&access_token=$access_token")->result->json;
  
  if (!$res->{email}) {
    return $self->render(text => "Can't get you'r email from facebook, please try another auth method.");
  }

  $self->session(email => $res->{email}, name => $res->{name}); # TODO: handle missing email
  $self->redirect_to('/');
}

1;
