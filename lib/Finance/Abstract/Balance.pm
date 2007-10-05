#!/usr/bin/perl

package Finance::Abstract::Balance;
use Moose;

use strict;
use warnings;

use Carp qw/croak/;

around new => sub {
	my $next = shift;
	my ( $class, %params ) = @_;

	my @values = @{ delete($params{values}) || [] };

	for (@values) {
		croak "$_ is not a Finance::Abstract::Value::Nominal"
			unless eval { $_->isa("Finance::Abstract::Value::Nominal") }
	}

	my %by_currency = map { $_->currency->unique_string => $_ } @values;

	croak "There must be only one value per currency"
		unless @values == keys %by_currency;

	$class->$next( %params, values_by_currency => \%by_currency );
};

has account => (
	isa => "Finance::Abstract::Account",
	is => "ro",
	required => 1,
);

has values_by_currency => (
	isa => "HashRef",
	reader   => "_values_by_currency",
	required => 1,
);

sub credit {
	my ( $self, @values ) = @_;
	$self->add_values( "credit", @values );
}

sub debit {
	my ( $self, @values ) = @_;
	$self->add_values( "debit", @values );
}

sub add_values {
	my ( $self, $type, @values ) = @_;

	if ( $type ne $self->account->normal_balance ) {
		@values = map { $_->neg } @values;
	}

	my %sums = %{ $self->_values_by_currency };

	foreach my $value ( @values ) {
		my $sum = \$sums{ $value->currency->unique_string };
		$$sum = Finance::Abstract::Value::Nominal->new(
			currency => $value->currency,
			amount   => ( $value->amount + ( $$sum ? $$sum->amount : 0 ) )
		);
	}

	$self->meta->clone_object( $self,
		values_by_currency => \%sums,
	);
}

sub purge_zero {
	my $self = shift;

	my %values = %{ $self->_values_by_currency };

	for ( keys %values ) {
		delete $values{$_} if $values{$_}->amount == 0;
	}

	$self->meta->clone_object( $self,
		values_by_currency => \%values,
	);
}

sub value {
	my $self = shift;

	croak "Ambiguous call to ->value - the balance must contain exactly one currency"
		unless keys %{ $self->_values_by_currency } == 1;
	
	( $self->values )[0];
}

sub values {
	my $self = shift;
	values %{ $self->_values_by_currency };
}

sub currencies {
	my $self = shift;
	map { $_->currency } $self->values;
}

sub has_currency {
	my ( $self, $currency ) = @_;
	exists $self->_values_by_currency->{ $currency->unique_string };
}

sub value_for_currency {
	my ( $self, $currency ) = @_;
	if ( my $value = $self->_values_by_currency->{ $currency->unique_string } ) {
		return $value;
	}

	return Finance::Abstract::Value::Nominal->new(
		currency => $currency,
		amount   => 0,
	);
}

sub validate {
	my $self = shift;
}

sub validate_transaction {
	my ( $self, $transcation ) = @_;
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Finance::Abstract::Balance - A set of values that an account has (per currency).

=head1 SYNOPSIS

	use Finance::Abstract::Balance;

=head1 DESCRIPTION

=cut


