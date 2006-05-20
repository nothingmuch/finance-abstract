#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;
use Test::Deep;

use ok "Finance::Abstract::AliasedClasses";

my $equity = Account->new( normal_balance => "credit" );
my $assets = Account->new;
my $inventory = Account->new;
my $liabilities = Account->new( normal_balance => "credit" );
my $expenses = Account->new;
my $revenue = Account->new( normal_balance => "credit" );

# start out with 10k
my $starting_equity = Transaction->new(
	transfers => [
		Transfer->new(
			account => $equity,
			type    => "credit",
			value   => Nominal->new( currency => Currency->new( code => "USD" ), amount => 10_000 ),
		),
		Transfer->new(
			account => $assets,
			type    => "debit",
			value   => Nominal->new( currency => Currency->new( code => "USD" ), amount => 10_000 ),
		),
	],
);

my $state = State->new;

lives_ok {
	$state = $state->add_transactions( $starting_equity );
} "state transformed";

cmp_deeply( [ $state->accounts ], set( $equity, $assets ), "equity and assets accounts involved" );

is( $state->account_balance( $equity )->value->amount, 10_000, "balance of equity account is 10k" );
is( $state->account_balance( $equity )->value->currency->code, "USD", "currency is USD" );

is( $state->account_balance( $assets )->value->amount, 10_000, "balance of assets account is 10k" );
is( $state->account_balance( $assets )->value->currency->code, "USD", "currency is USD" );

# buy 5k worth of Moose, 1k delivery

my $usd = Currency->new( code => "USD" );

$state = $state->add_transactions(
	Transaction->new(
		transfers => [
			Transfer->new(
				account => $assets,
				type    => "credit",
				value   => Nominal->new( currency => $usd, amount => 6000 ),
			),
			Transfer->new(
				account => $expenses,
				type    => "debit",
				value   => Nominal->new( currency => $usd, amount => 1000 ), # delivery
			),
			Transfer->new(
				account => $inventory, # really an asset
				type    => "debit",
				value   => Nominal->new( currency => $usd, amount => 5000 ),
			),
		],
	),
);

is( $state->account_balance( $equity )->value->amount, 10_000, "balance of equity account is 10k" );
is( $state->account_balance( $assets )->value->amount, 4_000, "balance of assets account is 4k" );
is( $state->account_balance( $expenses )->value->amount, 1_000, "balance of equity account is 1k" );
is( $state->account_balance( $inventory )->value->amount, 5_000, "balance of equity account is 5k" );

# sell the moose for 7500

$state = $state->add_transactions(
	Transaction->new(
		transfers => [
			Transfer->new(
				account => $inventory, # really an asset
				type    => "credit",
				value   => Nominal->new( currency => $usd, amount => 5000 ),
			),
			Transfer->new(
				account => $assets,
				type    => "debit",
				value   => Nominal->new( currency => $usd, amount => 7500 ),
			),
			Transfer->new(
				account => $revenue,
				type    => "credit",
				value   => Nominal->new( currency => $usd, amount => 2500 ),
			),
		],
	),
);



is( $state->account_balance( $equity )->value->amount, 10_000, "balance of equity account is 10k" );
is( $state->account_balance( $assets )->value->amount, 11_500, "balance of assets account is 11.5k" );
is( $state->account_balance( $expenses )->value->amount, 1_000, "balance of equity account is 1k" );
is( $state->account_balance( $inventory )->value->amount, 0, "balance of equity account is 0" );
is( $state->account_balance( $revenue )->value->amount, 2_500, "balance of equity account is 1.5k" );

is( scalar( @{ $state->transactions } ), 3, "three transactions so far" );

ok( !$state->has_account( $liabilities ), "liabilities account not in state" );
dies_ok {
	$state->account_balance( $liabilities )->value
} "can't call value with nothing in balance";
is( $state->account_balance( $liabilities )->value_for_currency( $usd )->amount, 0, "balance of liabilities account (not yet used) is 0");
