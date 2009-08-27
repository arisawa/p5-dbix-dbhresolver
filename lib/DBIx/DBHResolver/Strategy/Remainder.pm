package DBIx::DBHResolver::Strategy::Remainder;

use strict;
use warnings;
use Carp;

sub connect_info {
    my ($class, $resolver, $label, $args) = @_;
    croak "arguments require 'key'" unless $args->{key};
    my @nodes = $resolver->cluster($label);
    my $node_label = $nodes[$args->{key} % scalar @nodes];
    return $resolver->connect_info($node_label);
}

1;

__END__

=for stopwords resolver

=head1 NAME

DBIx::DBHResolver::Strategy::Remainder - Key based sharding strategy.

=head1 SYNOPSIS

  use DBIx::DBHResolver;

  DBIx::DBHResolver->load('/path/to/config.yaml');

  my $odd_number = 7;
  my $conn_info  = DBIx::DBHResolver->connect_info('MASTER', +{ strategy => 'Remainder', key => $odd_number });

=head1 DESCRIPTION

DBIx::DBHResolver::Strategy::Remainder is key based sharding strategy depends on remainder divided key by number of nodes.

=head1 AUTHOR

Kosuke Arisawa E<lt>arisawa@gmail.comE<gt>

=head1 SEE ALSO

=over

=item L<DBIx::DBHResolver>

=item L<DBI>

=back

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
