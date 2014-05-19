#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use v5.10;

use lib 'lib';

use Geo::SypexGeo;

binmode STDOUT, ':utf8';

my $geo = Geo::SypexGeo->new( 'data/SxGeoCity.dat' );

binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';

my $cities = {};

while ( my $ip = <STDIN> ) {
  chomp $ip;
  my $city = $geo->get_city( $ip );

  if ( !$city ) {
    say "$ip";
    next;
  }

  $cities->{$city} = $ip;
}

foreach my $city ( sort keys %$cities ) {
  say "$city $cities->{$city}";
}
