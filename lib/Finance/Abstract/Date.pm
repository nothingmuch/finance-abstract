#!/usr/bin/perl

package Finance::Abstract::Date;
use Moose;
use Moose::Util::TypeConstraints;

use strict;
use warnings;

use DateTime;

has datetime => (
	isa => subtype( DateTime => where { $_ && $_->time_zone->isa("DateTime::TimeZone::UTC") } ),
	is => "rw",
	default => sub {
		DateTime->from_epoch(
			epoch => time(),
			time_zone => "UTC",
		);
	},
);

__PACKAGE__;

__END__

=pod

=head1 NAME

Finance::Abstract::Date - An absolute point in time, for representing a unit's
value in history.

=head1 SYNOPSIS

	use Finance::Abstract::Date;

=head1 DESCRIPTION

=cut


