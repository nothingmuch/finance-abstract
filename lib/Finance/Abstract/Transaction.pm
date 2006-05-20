#!/usr/bin/perl

package Finance::Abstract::Transaction;
use Moose;

use strict;
use warnings;

use Math::BigFloat;
use Data::Alias;
use Tie::RefHash;

use Carp qw/croak/;

sub BUILD {
	my $self = shift;

	my %sums;

	foreach my $transfer ( $self->transfers ) {
		croak "$transfer is not a Finance::Abstract::Trasnfer object"
			unless eval { $transfer->isa("Finance::Abstract::Transfer") };

		my $value = $transfer->value;

		alias my $sum = $sums{ $value->currency->unique_string };

		$sum ||= Math::BigFloat->new(0);
		$sum += ( $transfer->is_credit ? -1 : 1 ) * $value->amount;
	}

	if (my @unbalanced = grep { $sums{$_} != 0 } keys %sums) {
		croak "Transaction isn't balanced (@unbalanced)";
	}
}

has transfers => (
	isa => "ArrayRef",
	is  => "ro",
	auto_deref => 1,
	required   => 1,
);

__PACKAGE__;

__END__

=pod

=head1 NAME

Finance::Abstract::Transaction - A set of transfers corresponding to one
transaction.

=head1 SYNOPSIS

	use Finance::Abstract::Transaction;

=head1 DESCRIPTION

=cut


