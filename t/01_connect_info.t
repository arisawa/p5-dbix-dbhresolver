use strict;
use Test::More;

plan tests => 3;

use DBIx::DBHResolver;

DBIx::DBHResolver->config(+{
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
    my $info = DBIx::DBHResolver->connect_info('LOCAL');
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
    my $info = DBIx::DBHResolver->connect_info(
        'MASTER',
        +{ strategy => 'Remainder', key => 6 },
    );
    is_deeply(
        {
            dsn => 'dbi:mysql:dbname=test;host=master1',
            user => 'root',
            password => "",
        },
        $info,
        "DBIx::DBHResolver::Strategy::Remainder - 1",
    );
}

{
    my $info = DBIx::DBHResolver->connect_info(
        'SLAVE',
        +{ strategy => 'Remainder', key => 7 },
    );
    is_deeply(
        {
            dsn => 'dbi:mysql:dbname=test;host=slave2',
            user => 'root',
            password => "",
        },
        $info,
        "DBIx::DBHResolver::Strategy::Remainder - 2",
    );
}
