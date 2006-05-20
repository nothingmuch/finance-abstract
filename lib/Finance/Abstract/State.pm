#!/usr/bin/perl

package Finance::Abstract::State;
use Moose;

use strict;
use warnings;

use Carp qw/croak/;
use Tie::RefHash;
use Data::Alias;

around new => sub {
	my $next = shift;
	my ( $class, %params ) = @_;

	tie my %by_account, "Tie::RefHash";

	for (@{ $params{balances} ||= [] }) {
		croak "$_ is not a Finance::Abstract::Balance"
			unless eval { $_->isa("Finance::Abstract::Balance") };

		$by_account{ $_->account } = $_;
	}

	croak "There must be only one value per currency"
		unless @{ $params{balances} } == keys %by_account;
	
	for (@{ $params{transactions} ||= [] } )  {
		croak "$_ is not a Finance::Abstract::Transaction"
			unless eval { $_->isa("Finance::Abstract::Transaction") }
	}

	$class->$next(
		transactions        => $params{transactions},
		history             => $params{history} || [],
		balances_by_account => \%by_account,
   );
};

has history => ( # Finance::Abstract::State
	isa => "ArrayRef",
	is  => "ro",
	auto_deref => 1,
);

has transactions => (
	isa => "ArrayRef",
	is  => "ro",
	auto_deref => 1,
	required   => 1,
);

has balances_by_account => ( # Finance::Abstract::Balance
	isa => "HashRef",
	reader   => "_balances_by_account",
	required => 1,
);

sub accounts {
	my $self = shift;
	keys %{ $self->_balances_by_account };
}

sub balances {
	my $self = shift;
	values %{ $self->_balances_by_account };
}

sub balance_for_account {
	my ( $self, $account ) = @_;
	$self->account_balance( $account );
}

sub has_account {
	my ( $self, $account ) = @_;
	exists $self->_balances_by_account->{ $account };
}

sub account_balance {
	my ( $self, $account ) = @_;

	if ( my $balance = $self->_balances_by_account->{ $account } ) {
		return $balance;
	}

	return Finance::Abstract::Balance->new( account => $account );
}

sub add_transactions {
	my ( $self, @transactions ) = @_;

	tie my %by_account, 'Tie::RefHash';
	%by_account = %{ $self->_balances_by_account };

	foreach my $txn ( @transactions ) {
		tie my %values_per_account, 'Tie::RefHash';

		foreach my $transfer ( $txn->transfers ) {
			alias my $balance = $by_account{ $transfer->account };
			$balance ||= Finance::Abstract::Balance->new( account => $transfer->account );

			my $method = $transfer->type;
			$balance = $balance->$method( $transfer->value );
		}

		foreach my $balance ( values %by_account ) {
			croak "$balance was not validated at transaction $txn"
				unless $balance->validate_transaction( $txn );
		}
	}

	foreach my $balance ( values %by_account ) {
		croak "$balance was not validated"
			unless $balance->validate;
	}

	return $self->meta->clone_object( $self,
		history => [ $self->history, $self ],
		transactions => [ $self->transactions, @transactions ],
		balances_by_account => \%by_account,
	);
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Finance::Abstract::State - The result of applying transactions (encapsulates
history, equity and balance).

=head1 SYNOPSIS

	use Finance::Abstract::State;

=head1 DESCRIPTION

=cut


