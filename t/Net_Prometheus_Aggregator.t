use Test2::V0;
use Net::Prometheus::Aggregator;

{
  my $npa = Net::Prometheus::Aggregator->new('tcp://1.2.3.4:55');
  isa_ok $npa, 'Net::Prometheus::Aggregator';
  isa_ok $npa->uri, 'URI';
  is $npa->uri->scheme, 'tcp',     '$npa->uri->scheme = tcp';
  is $npa->uri->host,   '1.2.3.4', '$npa->uri->host   = 1.2.3.4';
  is $npa->uri->port,   '55',      '$npa->uri->port   = 55';
};

{
  eval { Net::Prometheus::Aggregator->new };
  like $@, qr/uri required/, 'bad ctor, no uri';
}

{
  eval { Net::Prometheus::Aggregator->new( bless {}, 'Foo::Bar' ) };
  like $@, qr/uri must be an instance of URI/, 'bad ctor, not URI';
}

{
  eval { Net::Prometheus::Aggregator->new('http://1.2.3.4') };
  like $@, qr/uri must be of type tcp/, 'bad ctor, not tcp';
}

done_testing;
