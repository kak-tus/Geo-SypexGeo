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
my $parse;

$parse = $geo->parse( '87.250.250.203', 'en' ) or die "Cant parse 87.250.250.203";
$city = $parse->get_city();
say $city;

$parse = $geo->parse( '93.191.14.81' ) or die "Cant parse 93.191.14.81";
$city = $parse->get_city();
say $city;
my $country = $parse->get_country();
say $country;
my ($latitude, $longitude) = $parse->get_coordinates();
say "Latitude: $latitude Longitude: $longitude";


