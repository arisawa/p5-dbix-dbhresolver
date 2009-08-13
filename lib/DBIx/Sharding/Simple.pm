package DBIx::Sharding::Simple;

use strict;
use warnings;
use Carp;

sub connect_info {
    my ($class, $config, $label, $args) = @_;

    use Data::Dumper;
    my $nodes = $config->{sharding}->{$label};
    my $label_sharding = @{ $nodes }[$args->{key} % scalar @$nodes];
    my $info  = $config->{connect_info}->{$label_sharding};

    croak 'not found connect_info' unless $info;
    return (
        "dbi:mysql:dbname=$info->{DB};host=$info->{HOST}",
            $info->{USER},
            $info->{PASS},
    );
}

1;

__END__

=head1 NAME

DBIx::Sharding::Simple -

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
