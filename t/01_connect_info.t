use strict;
use Test::More;

plan tests => 3;

use DBIx::Sharding;

DBIx::Sharding->config(+{
    connect_info => +{
        LOCAL => +{
            dsn => 'dbi:mysql:dbname=test;host=localhost',
            user => 'root',
            password => "",
        },
        MASTER1 => +{
            dsn => 'dbi:mysql:dbname=test;host=master1',
            user => 'root',
            password => "",
        },
        MASTER2 => +{
            dsn => 'dbi:mysql:dbname=test;host=master2',
            user => 'root',
            password => "",
        },
        SLAVE1 => +{
            dsn => 'dbi:mysql:dbname=test;host=slave1',
            user => 'root',
            password => "",
        },
        SLAVE2 => +{
            dsn => 'dbi:mysql:dbname=test;host=slave2',
            user => 'root',
            password => "",
        },
    },
    clusters => +{
        MASTER => [ qw(MASTER1 MASTER2) ],
        SLAVE  => [ qw( SLAVE1  SLAVE2) ],
    },
});

{
    my $info = DBIx::Sharding->connect_info('LOCAL');
    is_deeply(
        {
            dsn => 'dbi:mysql:dbname=test;host=localhost',
            user => 'root',
            password => "",
        },
        $info,
        "single handle",
    );
}

{
    my $info = DBIx::Sharding->connect_info(
        'MASTER',
        +{ strategy => 'Simple', key => 6 },
    );
    is_deeply(
        {
            dsn => 'dbi:mysql:dbname=test;host=master1',
            user => 'root',
            password => "",
        },
        $info,
        "DBIx::Sharding::Simple - 1",
    );
}

{
    my $info = DBIx::Sharding->connect_info(
        'SLAVE',
        +{ strategy => 'Simple', key => 7 },
    );
    is_deeply(
        {
            dsn => 'dbi:mysql:dbname=test;host=slave2',
            user => 'root',
            password => "",
        },
        $info,
        "DBIx::Sharding::Simple - 2",
    );
}
