package WebService::CityGrid::Ads::Custom;

use strict;
use warnings;

=head1 NAME

WebService::CityGrid::Ads::Custom - CityGrid Custom Ads API

=cut

use Any::Moose;
use Any::URI::Escape;
use XML::LibXML;
use LWP::UserAgent;

has 'publisher' => ( is => 'ro', isa => 'Str', required => 1 );
has 'timeout' => ( is => 'ro', isa => 'Str', required => 1, default => 15 );

use constant DEBUG => $ENV{CG_DEBUG} || 0;

our $endpoint = "http://api.citygridmedia.com/ads/custom/v2/where";

our $VERSION = 0.01;

our $Ua = LWP::UserAgent->new( agent => join( '_', __PACKAGE__, $VERSION ) );
our $Parser = XML::LibXML->new;

=head1 METHODS

=over 4

=item query

  $res = $Cg->query({
      where => '90210',
      what  => 'pizza%20and%20burgers', });

Queries the web service.  Dies if the http request fails, so eval it!

=cut

sub query {
    my ( $self, $args ) = @_;

    my $url = "$endpoint?" . 'publisher=' . $self->publisher . '&';

    for (qw( what where )) {
        die "missing required arg $_" unless defined $_;
    }

    foreach my $arg ( keys %{$args} ) {

        die "invalid key $arg" unless grep { $arg eq $_ } qw( type what tag
              chain event first feature where lat lon radius from to page rpp
              sort publisher api_key placement format callback );

        $url .= join( '=', $arg, $args->{$arg} ) . '&';
    }
    $url = substr( $url, 0, length($url) - 1 );

    $Ua->timeout( $self->timeout );
    my $res = $Ua->get($url);

    die "query for $url failed!" unless $res->is_success;

    my $dom = $Parser->load_xml( string => $res->decoded_content );
    my @ads = $dom->documentElement->getElementsByTagName('ad');

    my @results;
    foreach my $ad (@ads) {

        warn( "raw location: " . $ad->toString ) if DEBUG;

        my %new_args;
        foreach my $attr (
            qw( type impression_id listing_id name street city state zip
            latitude longitude phone tagline description
            overall_review_rating ad_destination_url ad_display_url
            ad_image_url gross_ppe reviews offers distance
            attribution_text )
          )
        {

            my $val = $ad->getElementsByTagName($attr);
            if ($val) {
                my $firstchild = $val->[0]->firstChild;
                $new_args{$attr} = $firstchild->data if $firstchild;
            }
        }

        $new_args{id} = $ad->getAttribute('id');

        my $result = WebService::CityGrid::Ads::Custom::Ad->new( \%new_args );

        push @results, $result;
    }

    return \@results;
}

__PACKAGE__->meta->make_immutable;

package WebService::CityGrid::Ads::Custom::Ad;

use Any::Moose;

has 'id'                    => ( is => 'ro', isa => 'Int', required => 1 );
has 'type'                  => ( is => 'ro', isa => 'Str', required => 1 );
has 'impression_id'         => ( is => 'ro', isa => 'Str', required => 1 );
has 'listing_id'            => ( is => 'ro', isa => 'Str', required => 1 );
has 'name'                  => ( is => 'ro', isa => 'Str', required => 1 );
has 'street'                => ( is => 'ro', isa => 'Str', required => 1 );
has 'city'                  => ( is => 'ro', isa => 'Str', required => 1 );
has 'state'                 => ( is => 'ro', isa => 'Str', required => 1 );
has 'zip'                   => ( is => 'ro', isa => 'Str', required => 1 );
has 'latitude'              => ( is => 'ro', isa => 'Str', required => 1 );
has 'longitude'             => ( is => 'ro', isa => 'Str', required => 1 );
has 'phone'                 => ( is => 'ro', isa => 'Str', required => 0 );
has 'tagline'               => ( is => 'ro', isa => 'Str', required => 1 );
has 'description'           => ( is => 'ro', isa => 'Str', required => 0 );
has 'overall_review_rating' => ( is => 'ro', isa => 'Str', required => 0 );
has 'ad_destination_url'    => ( is => 'ro', isa => 'Str', required => 1 );
has 'ad_display_url'        => ( is => 'ro', isa => 'Str', required => 1 );
has 'ad_image_url'          => ( is => 'ro', isa => 'Str', required => 1 );
has 'gross_ppe'             => ( is => 'ro', isa => 'Str', required => 1 );
has 'reviews'               => ( is => 'ro', isa => 'Str', required => 0 );
has 'offers'                => ( is => 'ro', isa => 'Str', required => 0 );
has 'distance'              => ( is => 'ro', isa => 'Str', required => 0 );
has 'attribution_text'      => ( is => 'ro', isa => 'Str', required => 0 );

=cut

<ads><!-- Copyright 2010 Citysearch -->
<ad id="44162141">
  <type>local PFP</type>
  <impression_id>000700000932b305e40872467581a130fcb68c99a5</impression_id>
  <listing_id>81695</listing_id>
  <name>Tawanna Thai</name>
  <street>6236 Wilshire Blvd</street>
  <city>Los Angeles</city>
  <state>CA</state>
  <zip>90048</zip>
  <latitude>34.063288</latitude>
  <longitude>-118.364218</longitude>
  <phone>3236173940</phone>
  <tagline>April Weekend Night life at Tawanna Half Price Cocktails</tagline>
  <description></description>
  <overall_review_rating>9</overall_review_rating>
  <ad_destination_url>http://pfpc.citygridmedia.com/pfp/ad/v2?q=bjac6qs3coUk0ir2g2QpK5fr7t5uSgxhUVZd_OjyZ_j7WJ5jTzGNCm6a5gjjujKIvAcYNfii9gAfzGuWEyka6Wuw1Q6FuleB9vqOLQ7Pquxql1jdvwgZvmy9d920QIxfxr4OAYt4yi32QWZy-LeUG2nyu5xTEglMskwyMjYQ65cgGDKuHegqiuQjeqWbcOso8wQgfx90-DO6yFsSld8OEnW3hbfmz3CWiYWPw-glwpsKmbkSRbXdsRt6D4tDyOBVC86FdLg2sPB828vZSPn2J0xkxzyE5qkxMulU7qIMZaXFS6wuVVwz1x13WXX0A9aKLI6bBDtf_wqI6ETvZq5oNHyfQ4jBGIFcbKsvISnowiI</ad_destination_url>
  <ad_display_url>http://www.citysearch.com/profile/81695</ad_display_url>
  <ad_image_url>http://images.citysearch.net/assets/imgdb/adsimage/V-LOSCA-55119915_ID256188_pfp_image.gif</ad_image_url>
  <gross_ppe>0.01</gross_ppe>
  <reviews>93</reviews>
  <offers></offers>
  <distance></distance>
  <attribution_text></attribution_text>
</ad>
</ads>

=cut

1;

=head1 SYNOPSIS

  use WebService::CityGrid::Ads::Custom;
  $Cg = WebService::CityGrid::Ads::Custom->new(
      publisher => $my_pubid, );

  $url = $Cg->query({
      where => '90210',
      what  => 'pizza%20and%20burgers', });

=head1 DESCRIPTION

Currently just returns a url that can represents a call to the CityGrid Web Service.

=head1 SEE ALSO

L<http://developer.citysearch.com/docs/search/>

=head1 AUTHOR

Fred Moyer, E<lt>fred@slwifi.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Silver Lining Networks

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
