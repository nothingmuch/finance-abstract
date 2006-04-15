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


dies_ok {
	Currency->new( code => "My fabulous moose ISO code not" );
} "can't create currency with bogus ISO currency code";

can_ok( Date, "new" );

my $date = Date->new;

can_ok( $date, "datetime" );
isa_ok( $date->datetime, "DateTime" );

isa_ok( $date->datetime->time_zone, "DateTime::TimeZone::UTC" );


can_ok( Unit, "new" );
my $dollars_today = Unit->new( currency => $usd, date => $date );


can_ok( Value, "new" );
my $ten_dollars = Value->new( unit => $dollars_today, amount => 10 );
my $five_dollars = Value->new( unit => $dollars_today, amount => 5 );

ok( $ten_dollars->not_equals( $five_dollars ), "10 != 5" );

ok( $ten_dollars->minus( $five_dollars )->equals( $five_dollars ), "10 - 5 == 5" );

my $fifteen = $ten_dollars->plus( $five_dollars );

is( $fifteen->amount, 15, "amount of 15" );
ok( $fifteen->unit->equals( $ten_dollars->unit ), "units are the same" );


my $lb = Currency->new( code => "GBP" );
my $lb_today = Unit->new( currency => $lb, date => $date );

dies_ok {
	Value->new( unit => $lb_today, amount => 10 )->plus( $five_dollars );
} "can't add different units with different currencies";

my $in_a_while = DateTime->from_epoch( epoch => time() + 1000, time_zone => "UTC" );

my $tomorrow_dollar = Unit->new( currency => $usd, date => Date->new( datetime => $in_a_while ) );

dies_ok {
	Value->new( unit => $tomorrow_dollar, amount => 10 )->plus( $five_dollars );
} "can't add same currency but different date";

my $any_day_dollars = Nominal->new( currency => $usd, amount => 10 );
my $any_day_moose = Nominal->new( currency => $usd, amount => 5 );

is( $any_day_dollars->plus( $any_day_moose )->amount, 15, "nominal values arithmetic" );

my $any_day_lb = Nominal->new( currency => $lb, amount => 10 );

dies_ok {
	$any_day_lb->plus( $any_day_moose );
} "can't add nominal values with a different currency";
