package Net::Prometheus::Aggregator;

use strict;
use warnings;
use URI;
use URI::tcp;
use Carp ();

# ABSTRACT: Send observations to prometheus-aggregator

sub new {
  my($class, $uri) = @_;

  Carp::croak "uri required" unless defined $uri;
  
  if(ref $uri) {
    Carp::croak "uri must be an instance of URI, if passed in as a reference"
      unless eval { $uri->isa('URI') };
  } else {
    $uri = URI->new($uri);
  }
  
  Carp::croak "uri must be of type tcp" unless $uri->scheme eq 'tcp';

  my $self = bless {
    uri => $uri,
  }, $class;
  
  $self;
}

sub uri {
  shift->{uri};
}

1;
