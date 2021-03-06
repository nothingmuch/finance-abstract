#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;

use ok "Finance::Abstract::AliasedClasses";

can_ok( Currency, "new" );

my $usd = Currency->new( code => "USD" );

can_ok( $usd, "code" );
is( $usd->code, "USD", "correct ISO code" );

can_ok( Date, "new" );

my $date = Date->new;

can_ok( $date, "datetime" );
isa_ok( $date->datetime, "DateTime" );

isa_ok( $date->datetime->time_zone, "DateTime::TimeZone::UTC" );

can_ok( $date, "time_zone" );
is( $date->time_zone, $date->datetime->time_zone, "methods are delegated to the datetime object" );


can_ok( Unit, "new" );
my $dollars_today = Unit->new( currency => $usd, date => $date );


can_ok( Real, "new" );
my $ten_dollars = Real->new( unit => $dollars_today, amount => 10 );
my $five_dollars = Real->new( unit => $dollars_today, amount => 5 );

is( $ten_dollars->cmp( $five_dollars ), 1, "10 > 5" );

is( $ten_dollars->sub( $five_dollars )->cmp( $five_dollars ), 0, "10 - 5 == 5" );

my $fifteen = $ten_dollars->add( $five_dollars );

is( $fifteen->amount, 15, "amount of 15" );
ok( $fifteen->unit->equals( $ten_dollars->unit ), "units are the same" );


my $lb = Currency->new( code => "GBP" );
my $lb_today = Unit->new( currency => $lb, date => $date );

dies_ok {
	Real->new( unit => $lb_today, amount => 10 )->add( $five_dollars );
} "can't add different units with different currencies";

my $in_a_while = DateTime->from_epoch( epoch => time() + 1000, time_zone => "UTC" );

my $tomorrow_dollar = Unit->new( currency => $usd, date => Date->new( datetime => $in_a_while ) );

dies_ok {
	Real->new( unit => $tomorrow_dollar, amount => 10 )->add( $five_dollars );
} "can't add same currency but different date";

my $any_day_dollars = Nominal->new( currency => $usd, amount => 10 );
my $any_day_moose = Nominal->new( currency => $usd, amount => 5 );

is( $any_day_dollars->add( $any_day_moose )->amount, 15, "nominal values arithmetic" );

my $any_day_lb = Nominal->new( currency => $lb, amount => 10 );

dies_ok {
	$any_day_lb->add( $any_day_moose );
} "can't add nominal values with a different currency";
