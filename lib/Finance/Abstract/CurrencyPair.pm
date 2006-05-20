#!/usr/bin/perl

package Finance::Abstract::CurrencyPair;
use Moose;

use strict;
use warnings;

has base => (
	isa => "Finacne::Abstract::Currency",
	is  => "ro",
	required => 1,
);

has count => (
	isa => "Finacne::Abstract::Currency",
	is => "ro",
	required => 1,
);

has amount => ( # of count (base == 1)
	isa => "Math::BigFloat",
	is  => "ro",
	required => 1,
);

__PACKAGE__;

__END__

=pod

=head1 NAME

Finance::Abstract::CurrencyPair - An exchange rate between two currencies.

=head1 SYNOPSIS


=head1 DESCRIPTION

=cut


