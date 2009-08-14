use strict;
use Test::More tests => 3;

use DBIx::Sharding;
use Data::Dumper;

DBIx::Sharding->config(+{
    connect_info => +{
        LOCAL => +{
            dsn => 'dbi:mysql:dbname=test;host=localhost',
            user => 'root',
            password => "",
        },
        DIARY1_W => +{
            dsn => 'dbi:mysql:dbname=game_diary;host=db_dia1_m.mbga.dena.ne.jp',
            user => 'root',
            password => "",
        },
        DIARY2_W => +{
            dsn => 'dbi:mysql:dbname=game_diary;host=db_dia2_m.mbga.dena.ne.jp',
            user => 'root',
            password => "",
        },
        DIARY1_R => +{
            dsn => 'dbi:mysql:dbname=game_diary;host=db_dia1_s.mbga.dena.ne.jp',
            user => 'root',
            password => "",
        },
        DIARY2_R => +{
            dsn => 'dbi:mysql:dbname=game_diary;host=db_dia2_s.mbga.dena.ne.jp',
            user => 'root',
            password => "",
        },
    },
    sharding => +{
        DIARY_W => [ qw(DIARY1_W DIARY2_W) ],
        DIARY_R => [ qw(DIARY1_R DIARY2_R) ],
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
        'DIARY_W',
        +{ strategy => 'Simple', key => 6 },
    );
    is_deeply(
        {
            dsn => 'dbi:mysql:dbname=game_diary;host=db_dia1_m.mbga.dena.ne.jp',
            user => 'root',
            password => "",
        },
        $info,
        "DBIx::Sharding::Simple - 1",
    );
}

{
    my $info = DBIx::Sharding->connect_info(
        'DIARY_R',
        +{ strategy => 'Simple', key => 7 },
    );
    is_deeply(
        {
            dsn => 'dbi:mysql:dbname=game_diary;host=db_dia2_s.mbga.dena.ne.jp',
            user => 'root',
            password => "",
        },
        $info,
        "DBIx::Sharding::Simple - 2",
    );
}
