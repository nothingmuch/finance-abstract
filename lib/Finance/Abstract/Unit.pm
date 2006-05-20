#!/usr/bin/perl

package Finance::Abstract::Unit;
use Moose;

use strict;
use warnings;

use Scalar::Util ();

use Finance::Abstract::Currency;
use Finance::Abstract::Date;

has currency => (
	isa      => "Finance::Abstract::Currency",
	is       => "ro",
	required => 1,
	handles  => sub {
		my ( $attr, $delegate ) = @_;

		my @install;
		foreach my $method ( map { $_->{name} } $delegate->compute_all_applicable_methods ) {
			next if __PACKAGE__->can( $method );
			push @install, $method;
		}

		return map { $_ => $_ } @install;
	}
);

has date => (
	isa      => "Finance::Abstract::Date",
	is       => "ro",
	required => 1,
	default  => sub { Finance::Abstract::Date->new },
);

sub equals {
	my ( $x, $y ) = @_;
	Scalar::Util::refaddr( $x ) == Scalar::Util::refaddr( $y ) or # they should normally be the same
	$x->currency->equals( $y->currency ) && $x->date->equals( $y->date );
}

sub unique_string {
	my $self = shift;
	return sprintf( '%s@%s', $self->currency->unique_string, $self->date->datetime );
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Finance::Abstract::Unit - A unit with a a mid market value at a point in time.
Technically a touple of (Currency, Date).

=head1 SYNOPSIS

	use Finance::Abstract::Unit;

=head1 DESCRIPTION

=cut


