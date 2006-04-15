#!/usr/bin/perl

package Finance::Abstract::Currency;
use Moose;
use Moose::Util::TypeConstraints;

use strict;
use warnings;

use Locale::Currency;

use overload (
	"==" => "equals",
	'""' => "stringify",
);

has code => (
	isa => subtype( Str => where { defined Locale::Currency::code2currency( $_ ) } ),
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

__PACKAGE__;

__END__

=pod

=head1 NAME

Finance::Abstract::Currency - The financial tagged type of a unit - a currency symbol.

=head1 SYNOPSIS

	use Finance::Abstract::Currency;

=head1 DESCRIPTION

=cut


