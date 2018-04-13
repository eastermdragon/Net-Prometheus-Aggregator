package Net::Prometheus::Aggregator::Metric;

use strict;
use warnings;
use 5.012;
use JSON::MaybeXS qw( encode_json );

# ABSTRACT: Metric for prometheus-aggregator

sub new
{
  my($class, $socket, $labels, %decl) = @_;

  my $name = $decl{name};
  $decl{type} //= 'counter';  
  print $socket encode_json(\%decl), "\n";
 
  my $inc = sub {
    my $value = $_[1] // 1;
    print $socket "${name}{} $value\n";
  };
  
  my $self = bless {
    socket => $socket,
    inc    => $inc,
  }, $class;
  
  $self;
}

sub inc
{
  shift->{inc}->(@_)
}

1;
