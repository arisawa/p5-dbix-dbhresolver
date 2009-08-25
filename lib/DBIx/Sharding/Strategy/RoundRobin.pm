package DBIx::Sharding::Strategy::RoundRobin;

use strict;
use warnings;
use Carp;

sub connect_info {
    my ($class, $sharding, $label, $args) = @_;
    my @nodes = $sharding->cluster($label);
    my $node_label = $nodes[int rand scalar @nodes];
    return $sharding->connect_info($node_label);
}

1;

__END__

=for stopwords sharding

=head1 NAME

DBIx::Sharding::Strategy::RoundRobin - Label based round robin strategy.

=head1 SYNOPSIS

  use DBIx::Sharding;

  DBIx::Sharding->load('/path/to/config.yaml');

  my $conn_info  = DBIx::Sharding->connect_info('SLAVE', +{ strategy => 'RoundRobin' });

=head1 DESCRIPTION

DBIx::Sharding::Strategy::RoundRobin is label based round robin strategy depends on the node that takes it out from nodes.

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
