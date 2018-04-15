package Net::Prometheus::Aggregator;

use strict;
use warnings;
use 5.012;
use URI;
use URI::file;
use URI::tcp;  # ensure add as a dep
use URI::udp;  # ensure add as a dep
use Carp ();

# ABSTRACT: Send observations to prometheus-aggregator

sub new {
  my($class, $uri) = @_;

  Carp::croak "uri required" unless defined $uri;
  
  if(ref $uri) {
    Carp::croak "uri must be an instance of URI, if passed in as a reference"
      unless eval { $uri->isa('URI') };
    $uri = URI->clone; # make sure we keep our own copy
  } else {
    $uri = URI->new($uri);
  }
  
  Carp::croak "uri must be of type tcp, udp or file" unless $uri->scheme =~ qr/^(tcp|udp|file)$/;

  if($uri->scheme ne 'file') {
    $uri->host('localhost') unless defined $uri->host;
    $uri->port(8191) unless defined $uri->port;
  }

  my $self = bless {
    uri => $uri,
  }, $class;
  
  $self;
}

sub uri {
  shift->{uri};
}

sub proto {
  my $scheme = shift->uri->scheme;
  $scheme eq 'file' ? 'unix' : $scheme;
}

sub connect {
  my($self) = @_;
  
  $self->{socket} //= do {
    require IO::Socket::INET;
    IO::Socket::INET->new(
      PeerAddr => $self->uri->host,
      PeerPort => $self->uri->port,
      Proto    => $self->proto,
    ) or die $@;
  };
  
  $self;
}

1;
