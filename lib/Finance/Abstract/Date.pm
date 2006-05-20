#!/usr/bin/perl

package Finance::Abstract::Date;
use Moose;
use Moose::Util::TypeConstraints;

use strict;
use warnings;

use DateTime;

has datetime => (
	isa             => "DateTime",
	is              => "ro",
	default         => sub { DateTime->now() },
	handles         => sub {
		my ( $self, $delegate_meta ) = @_;

		my @install;
		foreach my $method ( map { $_->{name} } $delegate_meta->compute_all_applicable_methods() ) {
			next if __PACKAGE__->can( $method );
			next if Exporter->can( $method );
			next if $method eq "datetime";
			next if $method =~ / ^_ | ^set(?:_|$) | ^STORABLE | ^DESTROY$ | ^[A-Z]+$ /x;
			push @install, $method;
		}

		return map { $_ => $_ } @install;
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


