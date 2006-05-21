#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;

use ok "Finance::Abstract::AliasedClasses";

my $usd = Currency->new( code => "USD" );
my $usd_today = Unit->new( currency => $usd );

# these are strings so Perl doesn't get to touch them
my $huge = "98376815987594879288765817567557498798710.41415";
my $tiny = "2.345";

foreach my $spec (
	{ class => Nominal, currency => $usd },
	{ class => Real,    unit => $usd_today },
){
	my $class = delete $spec->{class};

	my $lots = $class->new( %$spec, amount => $huge );
	my $less = $lots->sub( $class->new( %$spec, amount => $tiny ) );
	my $least = $lots->sub( $less );

	isa_ok( $least->add(1), $class );
	is( $least->amount, $tiny, "accurate summing of huge floats" );
	is( $least->add( $least )->div(2)->amount, $tiny, "interaction with regular ints" );
	is( $least->mul( $lots )->mul(10)->div( $lots->mul(10) )->amount, $tiny, "big multiplication");
}

my $real = Real->new( unit => $usd_today, amount => 10 );
my $nominal = Nominal->new( currency => $usd, amount => 5 );

dies_ok { $real->add( $nominal ) } "can't mathify two incompatible values";
dies_ok { $nominal->add( $real ) } "can't mathify two incompatible values";

my $nominal2 = Nominal->new( currency => Currency->new(code => "EUR"), amount => 3 );

dies_ok { $nominal->add( $nominal2 ) } "can't mathify two compatible values with incompatible meta data";
dies_ok { $nominal2->add( $nominal ) } "can't mathify two compatible values with incompatible meta data";
