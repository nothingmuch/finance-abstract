#!/usr/bin/perl

package Finance::Abstract::Value::Nominal;
use Moose;

use strict;
use warnings;

use Carp qw/croak/;

extends "Finance::Abstract::Value::Base";

has currency => ( isa => "Finance::Abstract::Currency", is => "ro" );

override assert_compatible => sub {
	my ( $x, $y ) = @_;
	$x->assert_compatible_on_member( $y, "currency" );
};

__PACKAGE__;

__END__

=pod

=head1 NAME

Finance::Abstract::Value::Nominal - Nominal values are just an amount and a
currency, without being fixed to a date.

=head1 SYNOPSIS

	use Finance::Abstract::Value::Nominal;

=head1 DESCRIPTION

=head1 CAVEATS

Note that the unit of the left operand, or direct invocant will be preferred in
all comparison and arithmetic functions.

=cut


