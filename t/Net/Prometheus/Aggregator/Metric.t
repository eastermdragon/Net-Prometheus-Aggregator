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
  $npam->observe;
  is(next_line, "foo{} 1", "increment by one");
  $npam->observe(2);
  is(next_line, "foo{} 2", "increment by two");
}

{
  my $npam = Net::Prometheus::Aggregator::Metric::Counter->new($socket, [qw( bar baz )],
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

  $npam->observe([1,2]);
  is(next_line, 'foo{bar="1",baz="2"} 1',                'observe by one with labels');
  $npam->observe([3,4],5);
  is(next_line, 'foo{bar="3",baz="4"} 5',                'observe by six with labels');
  $npam->observe(['xor'],6);
  is(next_line, 'foo{bar="xor",baz=""} 6',               'increment with undef value label');
  $npam->observe(["xor\nnop",2],7);
  is(next_line, 'foo{bar="xor\nnop",baz="2"} 7',         'increment with new line in label');
  $npam->observe(['"double"',2],8);
  is(next_line, 'foo{bar="\\"double\\"",baz="2"} 8',     'increment with double quote');
  $npam->observe(['C:\\foo\\bar',2],9);
  is(next_line, 'foo{bar="C:\\\\foo\\\\bar",baz="2"} 9', 'increment with back slash');

  $npam->inc([1,2]);
  is(next_line, 'foo{bar="1",baz="2"} 1',                'inc by one with labels');
  $npam->inc([3,4],5);
  is(next_line, 'foo{bar="3",baz="4"} 5',                'inc by six with labels');
  $npam->inc(['xor'],6);
  is(next_line, 'foo{bar="xor",baz=""} 6',               'inc with undef value label');
  $npam->inc(["xor\nnop",2],7);
  is(next_line, 'foo{bar="xor\nnop",baz="2"} 7',         'inc with new line in label');
  $npam->inc(['"double"',2],8);
  is(next_line, 'foo{bar="\\"double\\"",baz="2"} 8',     'inc with double quote');
  $npam->inc(['C:\\foo\\bar',2],9);
  is(next_line, 'foo{bar="C:\\\\foo\\\\bar",baz="2"} 9', 'inc with back slash');
}

{
  my $npam = Net::Prometheus::Aggregator::Metric::Gauge->new($socket, [],
    name => "foo",
    help => "foo help",
  );

  isa_ok $npam, 'Net::Prometheus::Aggregator::Metric';
  is(
    next_json(),
    hash {
      field name => 'foo';
      field help => 'foo help';
      field type => 'gauge';
    },
    'define a simple counter',
  );
  
  $npam->observe(10);
  is(next_line, 'foo{} 10', 'gauge  observe 10');

  $npam->set(11);
  is(next_line, 'foo{} 11', 'gauge  set 11');
}  

done_testing;
