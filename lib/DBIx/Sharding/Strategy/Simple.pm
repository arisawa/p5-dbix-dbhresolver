package DBIx::Sharding::Strategy::Simple;

use strict;
use warnings;
use Carp;

sub connect_info {
    my ($class, $sharding, $label, $args) = @_;
    my $nodes = $sharding->config->{sharding}->{$label};
    my $node_label = @{ $nodes }[$args->{key} % scalar @$nodes];
    return $sharding->connect_info($node_label);
}

1;

__END__

=head1 NAME

DBIx::Sharding::Strategy::Simple - Key based sharding strategy.

=head1 SYNOPSIS

  use DBIx::Sharding;

  DBIx::Sharding->load('/path/to/config.yaml');

  my $odd_number = 7;
  my $conn_info  = DBIx::Sharding->connect_info('MASTER', +{ strategy => 'Simple', key => $odd_number });

=head1 DESCRIPTION

DBIx::Sharding::Strategy::Simple is key based sharding strategy depends on surplus divided key by nodes count.

=head1 AUTHOR

Kosuke Arisawa E<lt>arisawa@gmail.comE<gt>

=head1 SEE ALSO

=over

=item L<DBIx::Sharding>

=item L<DBI>

=back

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
