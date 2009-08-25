use Test::More;
use DBIx::Sharding;

plan tests => 7;

our %config = (
    connect_info => +{
        SLAVE1 => +{
            dsn => 'dbi:mysql:dbname=main;host=slave1',
            user => 'root',
            password => '',
            attrs => +{ RaiseError => 1, AutoCommit => 0, }
        },
        SLAVE2 => +{
            dsn => 'dbi:mysql:dbname=main;host=slave2',
            user => 'root',
            password => '',
            attrs => +{ RaiseError => 1, AutoCommit => 0, }
        },
        SLAVE3 => +{
            dsn => 'dbi:mysql:dbname=main;host=slave3',
            user => 'root',
            password => '',
            attrs => +{ RaiseError => 1, AutoCommit => 0, }
        },
    },
    clusters => +{
        SLAVE => [ qw/SLAVE1 SLAVE2 SLAVE3/ ],
    },
);

DBIx::Sharding->config(\%config);

for my $i ( map { $_ % 3 + 1 } (0..6) ) {
    is_deeply(
        DBIx::Sharding->connect_info('SLAVE', +{ strategy => 'RoundRobin' }),
        $config{connect_info}{"SLAVE$i"},
        'get SLAVE' . $i
    );
}
