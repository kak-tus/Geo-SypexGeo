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

$geo->parse( '87.250.250.203', 'en' ) or die "Cant parse 87.250.250.203";
$city = $geo->get_city();
say $city;

$geo->parse( '93.191.14.81' ) or die "Cant parse 93.191.14.81";
$city = $geo->get_city();
say $city;
my $country = $geo->get_country();
say $country;
my ($latitude, $longitude) = $geo->get_coordinates();
say "Latitude: $latitude Longitude: $longitude";


