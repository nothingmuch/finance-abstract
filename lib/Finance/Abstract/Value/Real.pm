#!/usr/bin/perl

package Finance::Abstract::Value::Real;
use Moose;

use strict;
use warnings;

use Carp qw/croak/;

use Math::BigFloat ();
use Locale::Currency::Format ();

extends "Finance::Abstract::Value::Base";

has unit => (
	isa      => "Finance::Abstract::Unit",
	is       => "ro",
	required => 1,
	handles  => ["currency"],
);

override assert_compatible => sub {
	my ( $x, $y ) = @_;
	$x->assert_compatible_on_member( $y, "unit" );
};

__PACKAGE__;

__END__

=pod

=head1 NAME

Finance::Abstract::Value::Real - A number of a certain financial unit (real value, as
opposed to nominal)

=head1 SYNOPSIS

	use Finance::Abstract::Value::Real;

=head1 DESCRIPTION

=cut


