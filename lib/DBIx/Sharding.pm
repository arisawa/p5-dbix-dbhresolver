package DBIx::Sharding;

use strict;
use warnings;

our $VERSION = '0.01';

use base qw(Class::Data::Inheritable);

__PACKAGE__->mk_classdata('config');

use DBI;

sub connect {
    my ($class, $dbh_id, $args) = @_;
    return DBI->connect($class->connect_info($dbh_id, $args));
}

sub connect_cached {
    my ($class, $dbh_id, $args) = @_;
    return DBI->connect($class->connect_info($dbh_id, $args));
}

sub connect_info {
    my ($class, $dbh_id) = @_;
    my $info = $class->config->{connect_info}->{$dbh_id};

    return (
        "dbi:mysql:dbname=$info->{database};host=$info->{host}",
        $info->{username},
        $info->{password},
    );
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
