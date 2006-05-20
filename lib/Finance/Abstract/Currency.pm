#!/usr/bin/perl

package Finance::Abstract::Currency;
use Moose;
use Moose::Util::TypeConstraints;

use strict;
use warnings;

has code => (
	isa => "Str",
	is => "ro",
);

sub equals {
	my ( $x, $y ) = @_;
	$x->code eq $y->code;
}

sub stringify {
	my $self = shift;
	return $self->code;
}

sub unique_string {
	my $self = shift;
	return sprintf( '%s::%s', blessed($self), $self->code );
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Finance::Abstract::Currency - A type of a unit (e.g. USD, frequent flier miles,
virgins, camels).

=head1 SYNOPSIS

	use Finance::Abstract::Currency;

=head1 DESCRIPTION

=cut


