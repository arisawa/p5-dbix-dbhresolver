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
    my ($class, $file) = @_;
    if (-e $file && -r $file) {
        $class->config(+{ connect_info => YAML::LoadFile($file) });
    } else {
        croak $!;
    }
}

sub connect {
    my ($class, $label, $args) = @_;
    return DBI->connect($class->connect_info($label, $args));
}

sub connect_cached {
    my ($class, $label, $args) = @_;
    return DBI->connect($class->connect_info($label, $args));
}

sub connect_info {
    my ($class, $label, $args) = @_;

    my $info;
    if (ref $args eq 'HASH') {
        unless ($args->{key} && $args->{strategy}) {
            croak "arguments require 'key', 'strategy'";
        }
        my $strategy_class = $args->{strategy} =~ /^\+(.+)$/
            ? join('::', (__PACKAGE__, 'Strategy', $1))
            : join('::', (__PACKAGE__, $args->{strategy}));

        $strategy_class->require;
        return $strategy_class->connect_info($class->config, $label, $args);
    } else {
        $info = $class->config->{connect_info}->{$label};
        croak 'not found connect_info' unless $info;
        return (
            "dbi:mysql:dbname=$info->{DB};host=$info->{HOST}",
            $info->{USER},
            $info->{PASS},
        );
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

20:23 (zigorou) +{ connect_info => +{ DB_USER_R => [], ... }, sharding => +{ DIARY_W => +{ strategy => '+Chariot::XXX::YYY', nodes => [ qw/DIARY_1_W DIARY_2_W .../ ] } } }
20:23 (zigorou) とか
20:23 (zigorou) こんなデータ構造はどうか
20:23 (zigorou) ping arisawa
20:23 (zigorou) ping arisawa
20:24 (zigorou) +Foo::Bar::Baz だと use Foo::Bar::Baz 相当で
20:25 (zigorou) Foo::Bar::Baz だと use DBIx::Sharding::Strategy::Foo::Bar::Baz;
20:25 (zigorou) tokane.
20:26 (zigorou) DBIx::Sharding::Strategy::PartionById とかさ
20:26 (zigorou) まぁいいや。
20:27 (zigorou) DBIx::Sharding->config->{connect_info}->{DB_USER_R} -> [ $dsn, $user_id, $password, \%attrs ]
20:27 (zigorou) って形で取得出来るの前提にしておきますか


=head1 AUTHOR

Kosuke Arisawa E<lt>arisawa@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
