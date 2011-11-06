#!/usr/bin/perl

use strict;
use warnings;

use WebService::CityGrid::Ads::Custom;

my $Cg = WebService::CityGrid::Ads::Custom->new({ publisher => 'test' });

my $res = $Cg->query({ what => 'restaurant', where => '90210' });

use Data::Dumper;
warn Dumper($res);
