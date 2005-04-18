package main;

use Test::More tests => 6;
use lib 't/lib';
use Catalyst::Test 'TestApp';
use File::stat;
use File::Slurp;
use HTTP::Date;

my $stat = stat($0);

{
    ok( my $response = request('/normal/2'),    'Normal Request'  );
    is( $response->code, 200,                 'OK status code'  );
    is( $response->content, '123',    'Normal request content', );
}

{
    ok( my $response = request('/subtest'),    'Sub Request'     );
    is( $response->code, 200,                 'OK status code'  );
    is( $response->content, '11433',    'Normal request content', );
}

