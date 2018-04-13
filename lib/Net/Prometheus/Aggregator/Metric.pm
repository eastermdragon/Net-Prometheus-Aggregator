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

  my $observe;
  
  if(@$labels) {
    $observe = sub {
      my $i=0;
      print $socket "${name}{", join(',',
        map { 
          $_ .                          # label
          '="' .
          (($_[1]->[$i++] // '')        # value
            =~ s/(["\\])/\\$1/gr        #  escape " and \ 
            =~ s/\n/\\n/gr              #  escape new line
          )
          . '"'
        } @$labels
      ), "} ", ($_[2] // 1), "\n";
    };
  } else {
    $observe = sub {
      print $socket "${name}{} ", ($_[1] // 1), "\n";
    };
  }
  
  my $self = bless {
    observe => $observe,
  }, $class;
  
  $self;
}

sub observe {
  shift->{observe}->(@_)
}

package Net::Prometheus::Aggregator::Metric::Counter;

use parent qw( Net::Prometheus::Aggregator::Metric );

sub new {
  my($class, $socket, $labels, %decl) = @_;
  $decl{type} = 'counter';
  $class->SUPER::new($socket, $labels, %decl);
}

*inc = \&Net::Prometheus::Aggregator::Metric::observe;

package Net::Prometheus::Aggregator::Metric::Gauge;

use parent qw( Net::Prometheus::Aggregator::Metric );

sub new {
  my($class, $socket, $labels, %decl) = @_;
  $decl{type} = 'gauge';
  $class->SUPER::new($socket, $labels, %decl);
}

*set = \&Net::Prometheus::Aggregator::Metric::observe;

1;
