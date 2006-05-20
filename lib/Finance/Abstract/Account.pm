#!/usr/bin/perl

package Finance::Abstract::Account;
use Moose;
use Moose::Util::TypeConstraints;

use strict;
use warnings;

enum NormalBalance => qw/debit credit/;

has normal_balance => (
	isa => "NormalBalance",
	is  => "ro",
	default => "debit",
);

__PACKAGE__;

__END__

=pod

=head1 NAME

Finance::Abstract::Account - A participant in transfers.

=head1 SYNOPSIS

	use Finance::Abstract::Account;

=head1 DESCRIPTION

An account is not much more than a unique ID in L<Finance::Abstract>.

=cut


