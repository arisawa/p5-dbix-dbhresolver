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

DBIx::Sharding::Strategy::Simple -

=head1 SYNOPSIS

  use DBIx::Sharding;

=head1 DESCRIPTION

DBIx::Sharding is

Kosuke Arisawa E<lt>arisawa@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
