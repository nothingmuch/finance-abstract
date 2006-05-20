#!/usr/bin/perl

package Finance::Abstract;

use strict;
use warnings;



__PACKAGE__;

__END__

=pod

=head1 NAME

Finance::Abstract - Financial arithmetic for double entry book-keeping.

=head1 SYNOPSIS

=head1 DESCRIPTION

This suite of modules provides objects for correct manipulation of financial
data, including precise calculation using L<Math::BigFloat>, support for
multiple currencies, inflation adjustment, and various validation routines.

The general use case is to be able to immutably calculate the application of
transfers and transactions onto accounts. Once a state change has been
calculated and balances OK the results can be written back to storage.

=head1 CLASSES

=head2 Currency

A "type" of money. This can be something like C<USD>, C<EUR> etc, or frequent
flier miles, or whatever. Anything you can count values with.

These things usually have symbols, too.

=head2 Date

A wrapper for DateTime. See L</Unit>.

=head2 Unit

A (Currency, Date) pair. Uniquifies currency units for inflation adjustment.
See also L<http://en.wikipedia.org/wiki/Constant_dollars>.

=head2 Value

=head3 Nominal

A nominal value is an amount and a currency. An account balance is a nominal value.

=head3 Real

A real value is an amount and a </Unit>. By normalizing different real values
of the same currency you adjust for inflation.

=head2 Account

A token used for balancing and transfers.

=head2 Transfer

A credit or a debit of a nominal value to/from an account.

=head2 Transaction

A set of Transfer objects that must balance.

=head2 State

A state is a set of balances and transactions. You can start with any state, apply transactions, and reach another state where the balances are different.

=head2 Balance

A set of Value::Nominal objects. An account can have 0 or more balances, one
per currency.

=head2 State

A state is a set of balances and transactions. You can start with any state,
apply transactions, and reach another state where the balances are different.

=head2 UnitPair

A unit pair is a base/count ratio between two units at known points in time.
When the points in time are the same it can act as an exchange rate.

=head2 CurrencyPair

A currency pair is a base/count ratio between two currencies at unspecified
points in time.

=head1 PERFORMANCE

Due to the pedantic nature of this code it's probably pretty slow. Using
L<Math::BigFloat::GMP> could help speed the math up, but the bulk of the
overhead is probably due to the purely functional approach of the code (no data
structures are edited).

=cut


