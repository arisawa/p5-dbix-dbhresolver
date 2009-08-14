package DBIx::Sharding;

use strict;
use warnings;
use Carp;
use UNIVERSAL::require;

our $VERSION = '0.01';

use base qw(Class::Data::Inheritable);

__PACKAGE__->mk_classdata('config');

use DBI;
use YAML;

sub load {
    my ( $class, $file ) = @_;
    if ( -e $file && -r $file ) {
        use Data::Dumper;
        $class->config( +{ connect_info => YAML::LoadFile($file) } );
    }
    else {
        croak $!;
    }
}

sub connect {
    my ( $class, $label, $args ) = @_;
    return DBI->connect( @{ $class->connect_info( $label, $args ) }
          {qw/dsn user password attrs/} );
}

sub connect_cached {
    my ( $class, $label, $args ) = @_;
    return DBI->connect_cached( @{ $class->connect_info( $label, $args ) }
          {qw/dsn user password attrs/} );
}

sub connect_info {
    my ( $class, $label, $args ) = @_;

    if ( ref $args eq 'HASH' ) {
        unless ( $args->{key} && $args->{strategy} ) {
            croak "arguments require 'key', 'strategy'";
        }
        my $strategy_class =
            $args->{strategy} =~ /^\+(.+)$/
          ? $1
          : join( '::', ( __PACKAGE__, 'Strategy', $args->{strategy} ) );

        $strategy_class->require;
        return $strategy_class->connect_info( $class, $label, $args );
    }
    else {
        croak 'not found connect_info'
          unless ( exists $class->config->{connect_info}->{$label} );
        return $class->config->{connect_info}->{$label};
    }
}

1;

__END__

=head1 NAME

DBIx::Sharding -

=head1 SYNOPSIS

  use DBIx::Sharding;

=head1 DESCRIPTION

DBIx::Sharding is

=head1 AUTHOR

Kosuke Arisawa E<lt>arisawa@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
