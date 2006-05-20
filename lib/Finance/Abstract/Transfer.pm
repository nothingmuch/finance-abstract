#!/usr/bin/perl

package Finance::Abstract::Transfer;
use Moose;
use Moose::Util::TypeConstraints qw/enum/;

use strict;
use warnings;

enum TransferType => qw/credit debit/;

has account => (
	isa => "Finance::Abstract::Account",
	is  => "ro",
	required => 1,
);

has type => (
	isa => "TransferType",
	is  => "ro",
	required => 1,
);

sub is_debit  { not shift->type eq "debit" }
sub is_credit { not shift->type eq "credit" }

has value => (
	isa => "Finance::Abstract::Value::Nominal",
	is => "ro",
	required => 1,
);

__PACKAGE__;

__END__

=pod

=head1 NAME

Finance::Abstract::Transfer - A sub-atomic operation inside a L<Finance::Abstract::Transaction>

=head1 SYNOPSIS

	use Finance::Abstract::Transfer;

=head1 DESCRIPTION

=cut


