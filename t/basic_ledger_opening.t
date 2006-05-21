#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;
use Test::Deep;

use ok "Finance::Abstract::AliasedClasses";

# assets
my $cashing_account = Account->new( normal_balance => "debit" );
my $inventory = Account->new( normal_balance => "debit" );

# equity
my $equity = Account->new( normal_balance => "credit" );

# liabilities
my $loans = Account->new( normal_balance => "credit" );

my $expenses = Account->new( normal_balance => "debit" );
my $revenue = Account->new( normal_balance => "credit" );

my $usd = Currency->new( code => "USD" );
my $eur = Currency->new( code => "EUR" );


my $state = State->new(
	balances => [
		Balance->new(
			account => $cashing_account,
			values => [
				Nominal->new( currency => $eur, amount => 1000 ),
				Nominal->new( currency => $usd, amount => 2000 ),
			],
		),
	],
);

# currency exchange
$state = $state->add_transactions(
	Transaction->new(
		transfers => [
			Transfer->new(
				account => $cashing_account,
				type    => "credit",
				value   => Nominal->new( currency => $eur, amount => 500 ),
			),
			Transfer->new(
				account => $expenses,
				type    => "debit",
				value   => Nominal->new( currency => $eur, amount => 500 ),
			),
			Transfer->new(
				account => $cashing_account,
				type    => "debit",
				value   => Nominal->new( currency => $usd, amount => 600 ),
			),
			Transfer->new(
				account => $expenses,
				type    => "credit",
				value   => Nominal->new( currency => $usd, amount => 600 ),
			),
		],
	),
);


cmp_deeply( [ $state->accounts ], bag( $expenses, $cashing_account ), "involved accoutns are correct" );
is( $state->account_balance( $cashing_account )->value_for_currency( $usd )->amount, 2600, "gained appropriate amount of USD" );
is( $state->account_balance( $cashing_account )->value_for_currency( $eur )->amount, 500, "lost appropriate amount of USD" );

