use Test2::V0;
use 5.010;
use Net::Prometheus::Aggregator::Metric;
use JSON::MaybeXS qw( decode_json );

my $buffer = '';
open my $socket, '>', \$buffer;

sub next_line {
  state @lines;
  unless(@lines)
  {
    open my $fh, '<', \$buffer;
    @lines = <$fh>;
    close $fh;
    chomp @lines;
    seek $socket, 0, 0;
    $buffer = '';
  }
  shift @lines;
}

sub next_json {
  decode_json(next_line());
}

{
  my $npam = Net::Prometheus::Aggregator::Metric->new($socket, [],
    name => "foo",
    help => "foo help",
  );
  isa_ok $npam, 'Net::Prometheus::Aggregator::Metric';  
  is(
    next_json(),
    hash {
      field name => 'foo';
      field help => 'foo help';
      field type => 'counter';
    },
    'define a simple counter',
  );
  $npam->inc;
  is(next_line, "foo{} 1", "increment by one");
  $npam->inc(2);
  is(next_line, "foo{} 2", "increment by two");
}

done_testing;
