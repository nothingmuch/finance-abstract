#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;

use ok "Finance::Abstract::AliasedClasses";

my $usd = Currency->new( code => "USD" );

dies_ok {
	Transaction->new(
		transfers => [
			Transfer->new(
				account => Account->new( normal_balance => "credit" ),
				type    => "debit",
				value   => Nominal->new( currency => $usd, amount => 1 ),
			),
		],
	);
} "can't create unbalanced transaction";


dies_ok {
	Transaction->new(
		transfers => [
			Transfer->new(
				account => Account->new( normal_balance => "credit" ),
				type    => "debit",
				value   => Nominal->new( currency => $usd, amount => 1 ),
			),
			Transfer->new(
				account => Account->new( normal_balance => "credit" ),
				type    => "credit",
				value   => Nominal->new( currency => $usd, amount => 2 ),
			),
		],
	);
} "can't create unbalanced transaction";

lives_ok {
	Transaction->new(
		transfers => [
			Transfer->new(
				account => Account->new( normal_balance => "credit" ),
				type    => "debit",
				value   => Nominal->new( currency => $usd, amount => 0 ),
			),
		],
	);
} "ok if the only transfer is 0";


lives_ok {
	Transaction->new(
		transfers => [
			Transfer->new(
				account => Account->new( normal_balance => "credit" ),
				type    => "debit",
				value   => Nominal->new( currency => $usd, amount => 2 ),
			),
			Transfer->new(
				account => Account->new( normal_balance => "credit" ),
				type    => "credit",
				value   => Nominal->new( currency => $usd, amount => 2 ),
			),
		],
	);
} "ok if transfers actually balance";
