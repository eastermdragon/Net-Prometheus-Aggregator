use Test2::V0;
use Net::Prometheus::Aggregator;

{
  my $npa = Net::Prometheus::Aggregator->new('tcp://1.2.3.4:55');
  isa_ok $npa, 'Net::Prometheus::Aggregator';
  isa_ok $npa->uri, 'URI';
  is $npa->uri->scheme, 'tcp',     '$npa->uri->scheme = tcp';
  is $npa->uri->host,   '1.2.3.4', '$npa->uri->host   = 1.2.3.4';
  is $npa->uri->port,   '55',      '$npa->uri->port   = 55';
  is $npa->proto,       'tcp',     '$npa->proto       = tcp';
};

{
  my $npa = Net::Prometheus::Aggregator->new('udp://1.2.3.4:55');
  isa_ok $npa, 'Net::Prometheus::Aggregator';
  isa_ok $npa->uri, 'URI';
  is $npa->uri->scheme, 'udp',     '$npa->uri->scheme = udp';
  is $npa->uri->host,   '1.2.3.4', '$npa->uri->host   = 1.2.3.4';
  is $npa->uri->port,   '55',      '$npa->uri->port   = 55';
  is $npa->proto,       'udp',     '$npa->proto       = udp';
};

{
  my $npa = Net::Prometheus::Aggregator->new('file:///path/to/socket');
  isa_ok $npa, 'Net::Prometheus::Aggregator';
  isa_ok $npa->uri, 'URI';
  is $npa->uri->scheme, 'file',            '$npa->uri->scheme = file';
  is $npa->uri->path,   '/path/to/socket', '$npa->uri->path = /path/to/socket';
  is $npa->proto,       'unix',            '$npa->proto       = unix';
};

{
  my $npa = Net::Prometheus::Aggregator->new('tcp:');
  isa_ok $npa, 'Net::Prometheus::Aggregator';
  is $npa->uri->scheme, 'tcp',       '$npa->uri->scheme = tcp';
  is $npa->uri->host,   'localhost', '$npa->uri->host   = localhost';
  is $npa->uri->port,   '8191',      '$npa->uri->port   = 8191';
  is $npa->proto,       'tcp',     '$npa->proto       = tcp';
}

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
  like $@, qr/uri must be of type tcp, udp or file/, 'bad ctor, not tcp';
}

done_testing;
