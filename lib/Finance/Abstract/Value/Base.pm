#!/usr/bin/perl

package Finance::Abstract::Value::Base;
use Moose;
use Moose::Util::TypeConstraints;

use strict;
use warnings;

use Locale::Currency::Format;
use Carp qw/croak/;

#coerce "Math::BigFloat" => from Num => via { Math::BigFloat->new };
# FIXME wait till coercion is fixed
sub new {
	my ( $class, %params ) = @_;
	$class->SUPER::new( amount => Math::BigFloat->new( delete $params{amount} ), %params );
}

has amount => ( isa => "Math::BigFloat", is => "ro" );

sub assert_compatible {
	my $self = shift;
	die "This is an abstract method. Please correct the class " . $self->meta->name;
}

sub assert_compatible_on_member {
	my ( $x, $y, $member ) = @_;
	croak "Can't compare " . $x->$member . " with " . $y->$member unless $x->$member == $y->$member;
}

sub not_equals {
	my ( $x, $y ) = @_;
	!$x->equals( $y );
}

sub equals {
	my ( $x, $y ) = @_;
	$x->assert_compatible( $y );
	$x->amount == $y->amount;
}

sub plus {
	my ( $x, $y ) = @_;
	$x->assert_compatible( $y );
	$x->meta->clone_object( $x, amount => $x->amount + $y->amount );
}

sub minus {
	my ( $x, $y ) = @_;
	$x->assert_compatible( $y );
	$x->meta->clone_object( $x, amount => $x->amount - $y->amount );
}

sub numify {
	my $self = shift;
	croak "Can't numify monetary units due to loss of type information";
}

sub stringify {
	my $self = shift;
	Locale::Currency::Format::currency_format( $self->unit->currency->code, $self->amount );
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Finance::Abstract::Value::Arithmetic - Common arithmetic operations on values, real and nominal

=head1 SYNOPSIS

	use Finance::Abstract::Value::Arithmetic;

=head1 DESCRIPTION

=cut


