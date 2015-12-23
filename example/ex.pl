#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use v5.10;

use lib 'lib';

use Geo::SypexGeo;

binmode STDOUT, ':utf8';

my $geo = Geo::SypexGeo->new( 'data/SxGeoCity.dat' );

my $city;

$city = $geo->get_city( '87.250.250.203', 'en' );
say $city;

$city = $geo->get_city( '93.191.14.81' );
say $city;

my $country = $geo->get_country( '93.191.14.81' );
say $country;

