use strict;
use warnings;
use DBIx::DBHResolver;
use FindBin;
use Test::More;

our $CONFIG_FILE = "$FindBin::Bin/db.conf.yaml";
our $CONFIG      = +{
    connect_info => {
        DB_W => {
            dsn      => 'dbi:mysql:dbname=user;host=db_w',
            user     => 'hoge',
            password => undef,
            attrs    => {
                AutoCommit => 0,
                PrintError => 0,
                RaiseError => 1,
                Warn       => 0,
            },
        },
        DB_R1 => {
            dsn      => 'dbi:mysql:dbname=user;host=db_r1',
            user     => 'hoge',
            password => undef,
            attrs    => {
                AutoCommit => 0,
                PrintError => 0,
                RaiseError => 1,
                Warn       => 0,
            },
        },
        DB_R2 => {
            dsn      => 'dbi:mysql:dbname=user;host=db_r2',
            user     => 'hoge',
            password => undef,
            attrs    => {
                AutoCommit => 0,
                PrintError => 0,
                RaiseError => 1,
                Warn       => 0,
            },
        },
    },
    clusters => { DB_R => [qw(DB_R1 DB_R2)], },
};

subtest 'using as static class' => sub {
    is_deeply( DBIx::DBHResolver->config, +{},
        'empty config before calling load method' );
    DBIx::DBHResolver->load($CONFIG_FILE);
    is_deeply( DBIx::DBHResolver->config, $CONFIG, 'loaded config' );
    done_testing;
};

subtest 'using as object' => sub {
    my $r = DBIx::DBHResolver->new;
    is_deeply( $r->config, +{}, 'empty config before calling load method' );
    $r->load($CONFIG_FILE);
    is_deeply( $r->config, $CONFIG, 'loaded config' );
    done_testing;
};

done_testing;
