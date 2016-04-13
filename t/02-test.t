use strict;
use warnings;
use utf8;

use Test::More tests => 2;

use Geo::SypexGeo;

my $geo = Geo::SypexGeo->new('data/SxGeoCity.dat');

my $info = $geo->parse('87.250.250.203');
is( $info->city(), 'Москва', 'City founded ok' );
is( $info->country(), 'ru', 'Country founded ok' );

