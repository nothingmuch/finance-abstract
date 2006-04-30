#!/usr/bin/perl

package Finance::Abstract::Unit;
use Moose;

use strict;
use warnings;

use Scalar::Util ();

has currency => (
	isa => "Finance::Abstract::Currency",
	is => "ro"
);
has date => (
	isa => "Finance::Abstract::Date",
	is => "ro",
);

sub equals {
	my ( $x, $y ) = @_;
	Scalar::Util::refaddr( $x ) == Scalar::Util::refaddr( $y ) or # they should normally be the same
	$x->currency->equals( $y->currency ) && $x->date->equals( $y->date );
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


