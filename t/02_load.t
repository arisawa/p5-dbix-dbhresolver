use strict;
use Test::More tests => 1;

use FindBin;
use DBIx::DBHResolver;

DBIx::DBHResolver->load("$FindBin::Bin/db.conf.yaml");

my $info = DBIx::DBHResolver->connect_info('USER_R');

is_deeply(
    {
        dsn => 'dbi:mysql:dbname=user;host=db_user_r.example.com',
        user => 'hoge',
        password => undef,
        attrs => {
            AutoCommit => 0,
            PrintError => 0,
            RaiseError => 1,
            Warn => 0,
        },
    },
    $info,
);
