#!/usr/bin/perl

package Finance::Abstract::Value::Base;
use Moose;
use Moose::Util::TypeConstraints;

use strict;
use warnings;

use Locale::Currency::Format;
use Carp qw/croak/;
use Scalar::Util qw/blessed/;

use Math::BigFloat ();
use Math::BigInt (); # it's autoloaded =/

#coerce "Math::BigFloat" => from Num => via { Math::BigFloat->new };
# FIXME wait till coercion is fixed
sub new {
	my ( $class, %params ) = @_;
	$class->SUPER::new( amount => Math::BigFloat->new( delete $params{amount} ), %params );
}

# this guy handles all the math operations
has amount => (
	isa     => "Math::BigFloat",
	is      => "ro",
	handles => sub {
		my ( $attr, $delegate_meta ) = @_;

		my @accum;
		foreach my $method ( $delegate_meta->compute_all_applicable_methods() ) {
			next if __PACKAGE__->can( $method->{name} );
			next if $method->{name} !~ / ^b | ^is_ /x;
			next if $method->{name} =~ / ^bnan$ | ^bzereo$ | ^binf$ | ^bone$ /x; # constructors and setters
		

			(my $new_name = $method->{name}) =~ s/^b//; # strip the 'b' off add, sub, div etc

			my $install_as = $method->{name};

			if ( $method->{name} =~ /^b/ ) {
				my $method_name = $method->{name};
				my $delegate_class = $delegate_meta->name;

				$install_as = sub {
					my $self = shift;

					if ( Scalar::Util::blessed( my $delegate = $self->amount ) ) {
						# make everything that isa Value::Base into a Math::BigFloat for the args
						my @args = map {
							(Scalar::Util::blessed($_) && $_->isa(__PACKAGE__))
							? ($self->assert_compatible( $_ ) && $_->amount)
							: $_
						} @_;

						# derive a copy of self with the changed amount
						my $res = $delegate->copy->$method_name( @args );
						return $res unless Scalar::Util::blessed($res) && $res->isa($delegate_class);
						return $self->meta->clone_instance( $self, amount => $res );
					}
					return;
				};
			}

			push @accum, $new_name => $install_as;
		}

		return @accum;
	}
);

sub assert_compatible {
	my $self = shift;
	die "This is an abstract method. Please correct the class " . $self->meta->name;
}

sub assert_compatible_on_member {
	my ( $x, $y, $member ) = @_;

	croak "Can't compare $x with $y because $y is not a subtype of $x"
		unless $y->isa( $x->meta->name );

	my ( $xm, $ym ) = ( $x->$member, $y->$member );
	croak "Can't compare $x/$xm with $y/$ym"
		unless blessed($xm) eq blessed($ym) && $x->$member->equals( $y->$member );
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


