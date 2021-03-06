package Geo::SypexGeo::Info;

use strict;
use warnings;
use utf8;
use v5.10;

use Carp qw( croak );
use Encode;

my @COUNTRY_ISO_MAP = (
  '',   'ap', 'eu', 'ad', 'ae', 'af', 'ag', 'ai', 'al', 'am', 'cw', 'ao',
  'aq', 'ar', 'as', 'at', 'au', 'aw', 'az', 'ba', 'bb', 'bd', 'be', 'bf',
  'bg', 'bh', 'bi', 'bj', 'bm', 'bn', 'bo', 'br', 'bs', 'bt', 'bv', 'bw',
  'by', 'bz', 'ca', 'cc', 'cd', 'cf', 'cg', 'ch', 'ci', 'ck', 'cl', 'cm',
  'cn', 'co', 'cr', 'cu', 'cv', 'cx', 'cy', 'cz', 'de', 'dj', 'dk', 'dm',
  'do', 'dz', 'ec', 'ee', 'eg', 'eh', 'er', 'es', 'et', 'fi', 'fj', 'fk',
  'fm', 'fo', 'fr', 'sx', 'ga', 'gb', 'gd', 'ge', 'gf', 'gh', 'gi', 'gl',
  'gm', 'gn', 'gp', 'gq', 'gr', 'gs', 'gt', 'gu', 'gw', 'gy', 'hk', 'hm',
  'hn', 'hr', 'ht', 'hu', 'id', 'ie', 'il', 'in', 'io', 'iq', 'ir', 'is',
  'it', 'jm', 'jo', 'jp', 'ke', 'kg', 'kh', 'ki', 'km', 'kn', 'kp', 'kr',
  'kw', 'ky', 'kz', 'la', 'lb', 'lc', 'li', 'lk', 'lr', 'ls', 'lt', 'lu',
  'lv', 'ly', 'ma', 'mc', 'md', 'mg', 'mh', 'mk', 'ml', 'mm', 'mn', 'mo',
  'mp', 'mq', 'mr', 'ms', 'mt', 'mu', 'mv', 'mw', 'mx', 'my', 'mz', 'na',
  'nc', 'ne', 'nf', 'ng', 'ni', 'nl', 'no', 'np', 'nr', 'nu', 'nz', 'om',
  'pa', 'pe', 'pf', 'pg', 'ph', 'pk', 'pl', 'pm', 'pn', 'pr', 'ps', 'pt',
  'pw', 'py', 'qa', 're', 'ro', 'ru', 'rw', 'sa', 'sb', 'sc', 'sd', 'se',
  'sg', 'sh', 'si', 'sj', 'sk', 'sl', 'sm', 'sn', 'so', 'sr', 'st', 'sv',
  'sy', 'sz', 'tc', 'td', 'tf', 'tg', 'th', 'tj', 'tk', 'tm', 'tn', 'to',
  'tl', 'tr', 'tt', 'tv', 'tw', 'tz', 'ua', 'ug', 'um', 'us', 'uy', 'uz',
  'va', 'vc', 've', 'vg', 'vi', 'vn', 'vu', 'wf', 'ws', 'ye', 'yt', 'rs',
  'za', 'zm', 'me', 'zw', 'a1', 'xk', 'o1', 'ax', 'gg', 'im', 'je', 'bl',
  'mf', 'bq', 'ss'
);

sub new {
  my ( $class, $info, $lang ) = @_;
  my $self = {};
  $self->{lang} = $lang;
  $self->{info} = $info;
  bless $self, $class;
  return $self;
}

sub city {
  my __PACKAGE__ $self = shift;
  my $info = $self->{info} || return;
  my $lang = $self->{lang};

  my $city;
  if ( $lang && $lang eq 'en' ) {
    $city = $info->[6];
  }
  else {
    $city = $info->[5];
  }
  return unless $city;

  return decode_utf8($city);
}

sub country {
  my __PACKAGE__ $self = shift;
  my $info = $self->{info} || return;

  my $country;
  if ( $info->[1] =~ /\D/ ) {
    $country = $info->[1];
  }
  else {
    $country = $COUNTRY_ISO_MAP[ $info->[1] ];
  }

  return $country;
}

sub coordinates {
  my __PACKAGE__ $self = shift;
  my $info = $self->{info} || return;
  return ( $info->[3], $info->[4] );
}

1;
