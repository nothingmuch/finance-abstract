#!/usr/bin/perl

package Finance::Abstract::AliasedClasses;

use strict;
use warnings;

use base qw/Exporter/;

use aliased ();

BEGIN {
	our @EXPORT;
	foreach my $submodule ( qw/
		Unit
		Currency
		Value::Real
		Value::Nominal
		Date
		Account
		Unit::Exchange
		Unit::Normalize
	/ ){
		aliased->import( "Finance::Abstract::$submodule" );
		( my $alias = $submodule ) =~ s/.*(?:::|')//;
		push @EXPORT, $alias;
	}
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Finance::Abstract::AliasedClasses - 

=head1 SYNOPSIS

	use Finance::Abstract::AliasedClasses;

=head1 DESCRIPTION

=cut


