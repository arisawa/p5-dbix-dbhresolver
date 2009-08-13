use strict;
use Test::More tests => 9;

use DBIx::Sharding;
use Data::Dumper;

DBIx::Sharding->config(+{
    connect_info => +{
        LOCAL => +{
            HOST => 'localhost',
            DB => 'test',
            USER => 'root',
            PASS => "",
        },
        DIARY1_W => +{
            HOST => 'localhost',
            DB => 'diary1_w',
            USER => 'root',
            PASS => "",
        },
        DIARY2_W => +{
            HOST => 'localhost',
            DB => 'diary2_w',
            USER => 'root',
            PASS => "",
        },
        DIARY1_R => +{
            HOST => 'localhost',
            DB => 'diary1_r',
            USER => 'root',
            PASS => "",
        },
        DIARY2_R => +{
            HOST => 'localhost',
            DB => 'diary2_r',
            USER => 'root',
            PASS => "",
        },
    },
    sharding => +{
        DIARY_W => [ qw(DIARY1_W DIARY2_W) ],
        DIARY_R => [ qw(DIARY1_R DIARY2_R) ],
    },
});

{
    my $test = "single handle";
    my ($dsn, $user, $pass) = DBIx::Sharding->connect_info('LOCAL');
    is($dsn, 'dbi:mysql:dbname=test;host=localhost', "$test dsn");
    is($user, 'root', "$test user");
    is($pass, "", "$test password");
}

{
    my $test = "DBIx::Sharding::Simple - 1";
    my ($dsn, $user, $pass) = DBIx::Sharding->connect_info(
        'DIARY_W',
        +{ strategy => 'Simple', key => 6 },
    );
    is($dsn, 'dbi:mysql:dbname=diary1_w;host=localhost', "$test dsn");
    is($user, 'root', "$test user");
    is($pass, "", "$test password");
}

{
    my $test = "DBIx::Sharding::Simple - 2";
    my ($dsn, $user, $pass) = DBIx::Sharding->connect_info(
        'DIARY_R',
        +{ strategy => 'Simple', key => 7 },
    );
    is($dsn, 'dbi:mysql:dbname=diary2_r;host=localhost', "$test dsn");
    is($user, 'root', "$test user");
    is($pass, "", "$test password");
}
