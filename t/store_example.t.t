#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use List::Util qw/sum/;

use ok "Finance::Abstract::AliasedClasses";

{
	package MyAccount;
	use Moose;

	extends "Finance::Abstract::Account";

	has balance => (
		isa => "Finance::Abstract::Balance",
		is  => "rw",
		default => sub { Finance::Abstract::Balance->new( account => shift ) },
	);

	has transactions => (
		isa => "ArrayRef",
		is  => "rw",
		default => sub { [] },
	);
}

my %accounts = map {
	$_ => MyAccount->new(
		normal_balance => ( /credit/ ? "credit" : "debit" ),
	),
} qw/cash inventory credit_card/;
my @ledger;




sub usd ($) { Nominal->new( currency => Currency->new( code => "usd" ), amount => shift ) }
sub debit ($$) { transfer(shift, "debit", shift) }
sub credit ($$) { transfer(shift, "credit", shift) }
sub transfer ($$$) {
	my ( $account, $type, $value ) = @_;
	Transfer->new( account => $accounts{$account}, type => $type, value => $value );
}
sub txn {
	Transaction->new( transfers => [ @_ ] );
}

isa_ok( usd(500), Nominal, "usd()" );
is( usd(500)->amount, 500, "usd() keeps amount" );
isa_ok( usd(500)->currency, Currency, "usd() currency" );
isa_ok( credit(cash => usd(500)), Transfer, "credit()" );


sub apply {
	# compute the initial state
	my $state = State->new(
		balances => [ map { $_->balance } values %accounts ],
	);

	my $resulting_state = $state->add_transactions( @_ );

	push @ledger, @_;

	foreach my $account ( keys %accounts ) {
		$accounts{$account}->balance( $resulting_state->account_balance( $accounts{$account} ) );
	}

	foreach my $txn ( $resulting_state->transactions ) {
		foreach my $account ( $txn->accounts ) {
			push @{ $account->transactions }, $txn;
		}
	}
}

apply(
	txn( # buy with the credit card
		credit( credit_card => usd(1000) ),
		debit(  inventory   => usd(1000) ),
	),
);

is( $accounts{cash}->balance->value_for_currency( Currency->new( code => "usd" ) )->amount, 0, "no change to cash" );
is( $accounts{inventory}->balance->value->amount, 1000, "1k of inventory" );
is( $accounts{credit_card}->balance->value->amount, 1000, "1k of liabilities for credit card" );

is( scalar( @{ $accounts{credit_card}->transactions } ), 1, "one transaction involving CC" );

apply(
	txn( # pay off some of the CC debt
		credit( cash        => usd(500) ),
		debit(  credit_card => usd(500) ),
	),
);

is( $accounts{cash}->balance->value->amount, -500, ".5k overdraft" );
is( $accounts{credit_card}->balance->value->amount, 500, ".5k credit card debt" );

is( scalar( @{ $accounts{credit_card}->transactions } ), 2, "two transactions involving CC" );
is( scalar( @{ $accounts{cash}->transactions } ), 1, "one transaction involving cash" );

is( sum(map { ( $_->normal_balance eq "credit" ? -1 : 1 ) * $_->balance->value->amount } values %accounts ), 0, "acccounts are all balanced" );

