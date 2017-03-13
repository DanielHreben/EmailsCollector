package EmailsCollector;

use Mojo::UserAgent;
use Data::Dumper;
use Mojo::Base 'Mojolicious';

use EmailsCollector::Controller::OAuth;

sub startup {
  my $self = shift;

  $self->_init_oauth();

  my $r = $self->routes();

  $r->post('/auth/sendmail/authenticate')->to('sendmail#authenticate');
  $r->get('/auth/sendmail/callback')->to('sendmail#callback');

  $r->get('/login')->to('users#login');
  $r->get('/logout')->to('users#logout');
  $r->under->to('users#check_session')->get('/')->to('users#profile');
}

sub _init_oauth {
  my $self = shift;
  my $credentials = $self->plugin('Config')->{oauth};

  if (my $google = $credentials->{google}) {
    my ($key, $secret) = @$google;

    $self->plugin('Web::Auth',
      module      => 'Google',
      key         => $key,
      secret      => $secret,
      scope       => 'email',
      on_finished => \&EmailsCollector::Controller::OAuth::google,
    );
  }

  if (my $github = $credentials->{github}) {
    my ($key, $secret) = @$github;

    $self->plugin('Web::Auth',
      module      => 'Github',
      key         => $key,
      secret      => $secret,
      on_finished => \&EmailsCollector::Controller::OAuth::github,
    );    
  }

  if (my $facebook = $credentials->{facebook}) {
    my ($key, $secret) = @$facebook;

    $self->plugin('Web::Auth',
      module      => 'Facebook',
      key         => $key,
      secret      => $secret,
      scope       => 'email',
      on_finished => \&EmailsCollector::Controller::OAuth::facebook
    );
  }
}

1;
