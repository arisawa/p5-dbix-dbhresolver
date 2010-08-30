package DBIx::DBHResolver::Strategy::Key;

use strict;
use warnings;
use Carp;
use Data::Util qw(is_array_ref is_number neat);

our $VERSION = '0.01';

sub connect_info {
    my ( $class, $resolver, $node, $args ) = @_;
    my @keys =
      is_array_ref( $args->{key} ) ? @{ $args->{key} } : ( $args->{key} );
    my $key = shift @keys;

    unless ( is_number($key) ) {
        croak sprintf( 'args has not key field or no number value (key: %s)',
            neat($key) );
    }

    my @nodes         = $resolver->clusters($node);
    my $resolved_node = $nodes[ $key % scalar @nodes ];

    return $resolver->connect_info( $resolved_node, \@keys );
}

1;

__END__

=head1 NAME

DBIx::DBHResolver::Strategy::Key - Key based sharding strategy

=head1 SYNOPSIS

  use DBIx::DBHResolver::Strategy::Key;

=head1 DESCRIPTION

=head2 METHODS

=head1 AUTHOR

Toru Yamaguchi E<lt>zigorou@cpan.org<gt>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

# Local Variables:
# mode: perl
# perl-indent-level: 4
# indent-tabs-mode: nil
# coding: utf-8-unix
# End:
#
# vim: expandtab shiftwidth=4:
