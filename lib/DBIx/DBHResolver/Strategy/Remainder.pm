package DBIx::DBHResolver::Strategy::Remainder;

use strict;
use warnings;
use Carp;

our $VERSION = '0.10';

sub connect_info {
    my ( $class, $resolver, $node, $args ) = @_;
    croak q|args has not 'key' field| unless ( defined $args->{key} && $args->{key} =~ m/^\d+$/ );
    my @nodes      = $resolver->cluster($node);
    my $resolved_node = $nodes[ $args->{key} % scalar @nodes ];
    return $resolver->connect_info($resolved_node);
}

1;

=head1 NAME

DBIx::DBHResolver::Strategy::Remainder - Key based sharding strategy.

=head1 SYNOPSIS

  use DBIx::DBHResolver;

  my $r = DBIx::DBHResolver->new;
  $r->config(+{
    clusters => +{
      diary_master => [qw/diary001_master diary002_master diary003_master diary004_master/]
    },
    connect_info => +{
      diary001_master => +{ ... },
      diary002_master => +{ ... },
      diary003_master => +{ ... },
      diary004_master => +{ ... },
    }
  });

  my $dbh_001 = $r->connect( 'diary_master', +{ key => 4, strategy => 'Remainer' } ); # key % 4 == 0
  my $dbh_002 = $r->connect( 'diary_master', +{ key => 5, strategy => 'Remainer' } ); # key % 4 == 1
  my $dbh_003 = $r->connect( 'diary_master', +{ key => 6, strategy => 'Remainer' } ); # key % 4 == 2
  my $dbh_004 = $r->connect( 'diary_master', +{ key => 7, strategy => 'Remainer' } ); # key % 4 == 3

=head1 DESCRIPTION

DBIx::DBHResolver::Strategy::Remainder is key based sharding strategy depends on remainder divided key by number of nodes.

=head1 METHOD

=head2 connect_info( $resolver, $node, $args )

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
