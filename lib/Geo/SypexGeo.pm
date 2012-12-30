package Geo::SypexGeo;

our $VERSION = '0.1';

use strict;
use warnings;
use utf8;

use Carp qw( croak );
use Encode;
use Socket;
use POSIX;

use fields qw( db_file b_idx_str m_idx_str range b_idx_len m_idx_len db_items id_len block_len max_region max_city db_begin regions_begin cities_begin );

sub new {
  my $class = shift;
  my $file  = shift;

  my $me = fields::new( $class );

  open( my $fl, $file ) || croak( 'Could not open db file' );
  binmode $fl, ':bytes';

  read $fl, my $header, 32;
  croak 'File format is wrong' if $header !~ m/^SxG(.*)$/;

  my @info = unpack 'CNCCCnnNCnnNN', $1;
  croak 'File format is wrong' if $info[ 4 ] * $info[ 5 ] * $info[ 6 ] * $info[ 7 ] * $info[ 1 ] * $info[ 8 ] == 0;

  read $fl, $me->{ 'b_idx_str' }, $info[ 4 ] * 4;
  read $fl, $me->{ 'm_idx_str' }, $info[ 5 ] * 4;

  $me->{ 'range' } = $info[ 6 ];
  $me->{ 'b_idx_len' } = $info[ 4 ];
  $me->{ 'm_idx_len' } = $info[ 5 ];
  $me->{ 'db_items' } = $info[ 7 ];
  $me->{ 'id_len' } = $info[ 8 ];
  $me->{ 'block_len' } = 3 + $me->{ 'id_len' };
  $me->{ 'max_region' } = $info[ 9 ];
  $me->{ 'max_city' } = $info[ 10 ];

  $me->{ 'db_begin' } = tell $fl;

  $me->{ 'regions_begin' } = $me->{ 'db_begin' } + $me->{ 'db_items' } * $me->{ 'block_len' };
  $me->{ 'cities_begin' } = $me->{ 'regions_begin' } + $info[ 11 ];

  $me->{ 'db_file' } = $file;

  close $fl;

  return $me;
}

sub get_city {
  my $me = shift;
  my $ip = shift;

  my $seek = $me->get_num( $ip );
  return decode_utf8( $me->parse_city( $seek ) ) if $seek;

  return undef;
}

sub get_num {
  my $me = shift;
  my $ip = shift;

  my $ip1n;
  {
    no warnings;
    $ip1n = int $ip;
  }

  return undef if !$ip1n || $ip1n == 10 || $ip1n == 127 || $ip1n >= $me->{ 'b_idx_len' };
  my $ipn = ip2long( $ip );
  $ipn = pack( 'N', $ipn );

  my @blocks = unpack "NN", substr( $me->{ 'b_idx_str' } , ( $ip1n - 1 ) * 4, 8 );

  my $part = $me->search_idx( $ipn, floor( $blocks[ 0 ] / $me->{ 'range' } ), floor( $blocks[ 1 ] / $me->{ 'range' } ) - 1 );

  my $min = $part > 0 ? $part * $me->{ 'range' } : 0;
  my $max = $part > $me->{ 'm_idx_len' } ? $me->{ 'db_items' } : ( $part + 1 ) * $me->{ 'range' };

  $min = $blocks[ 0 ] if $min < $blocks[ 0 ];
  $max = $blocks[ 1 ] if $max > $blocks[ 1];
  my $len = $max - $min;

  open( my $fl, $me->{ 'db_file' } ) || croak( 'Could not open db file' );
  binmode $fl;
  seek $fl, $me->{ 'db_begin' } + $min * $me->{ 'block_len' }, 0;
  read $fl, my $buf, $len * $me->{ 'block_len' };
  close $fl;

  return $me->search_db( $buf, $ipn, 0, $len - 1 );
}

sub search_idx {
  my $me = shift;
  my $ipn = shift;
  my $min = shift;
  my $max = shift;

  my $offset;
  while ( $max - $min > 8 ) {
    $offset = ( $min + $max ) >> 1;

    if ( encode_utf8($ipn) gt encode_utf8(substr( ( $me->{ 'm_idx_str' } ), $offset * 4, 4 ) )) {
      $min = $offset;
    }
    else {
      $max = $offset;
    }
  }

  while ( encode_utf8($ipn) gt encode_utf8( substr( $me->{ 'm_idx_str' }, $min * 4, 4 ) ) && $min++ < $max ) {
  }

  return  $min;
}

sub search_db {
  my $me = shift;
  my $str = shift;
  my $ipn = shift;
  my $min = shift;
  my $max = shift;

  if( $max - $min > 0 ) {
    $ipn = substr( $ipn, 1 );
    my $offset;
    while ( $max - $min > 8 ){
      $offset = ( $min + $max ) >> 1;

      if ( encode_utf8( $ipn ) gt encode_utf8( substr( $str, $offset * $me->{ 'block_len' }, 3 ) ) ) {
        $min = $offset;
      }
      else {
        $max = $offset;
      }
    }

    while ( encode_utf8( $ipn ) ge encode_utf8( substr( $str, $min * $me->{ 'block_len' }, 3 ) ) && $min++ < $max ){}
  }
  else {
    return hex( bin2hex( substr( $str, $min * $me->{ 'block_len' } + 3 , 3 ) ) );
  }

  return hex( bin2hex( substr( $str, $min * $me->{ 'block_len' } - $me->{ 'id_len' }, $me->{ 'id_len' } ) ) );
}

sub bin2hex {
  my $str = shift;
  $str =~ s/(.)/sprintf( '%x', ord( $1 ) )/eg;
  return $str;
}

sub ip2long {
  return unpack( 'l*', pack( 'l*', unpack( 'N*', inet_aton( shift ) ) ) );
}

sub parse_city {
  my $me   = shift;
  my $seek = shift;

  open( my $fl, $me->{ 'db_file' } ) || croak( 'Could not open db file' );
  binmode $fl;
  seek $fl, $me->{ 'cities_begin' } + $seek, 0;
  read $fl, my $buf, $me->{ 'max_city' };
  close $fl;

  my @cities = split '\0', substr( $buf, 15 );

  return $cities[ 0 ];
}

1;

=head1 NAME

Geo::SypexGeo - API to detect cities by IP thru Sypex Geo database

=head1 SYNOPSIS

 use Geo::SypexGeo;
 my $geo = Geo::SypexGeo->new( './SxGeoCity.dat' );
 my $city = $geo->get_city( '87.250.250.203' );

=head1 DESCRIPTION

Sypex Geo is a database to detect cities by IP.

http://sypexgeo.net/

The database of IPs is included into distribution, but it is better to download latest version at http://sypexgeo.net/ru/download/.

The database is availible now only with a names of the cities in Russian language.

This module now is detect only city name and don't use any features to speed up of detection. In the future I plan to add more functionality.

=head1 SOURCE AVAILABILITY

The source code for this module is available from Github
at https://github.com/kak-tus/Geo-SypexGeo.git

=head1 AUTHOR

Andrey Kuzmin, E<lt>kak-tus@mail.ruE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Andrey Kuzmin

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
