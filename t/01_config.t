use strict;
use Test::More tests => 3;

use DBIx::Sharding;
use Data::Dumper;

my @config_keys = qw(host database username password);

DBIx::Sharding->config(+{
    connect_info => +{
        LOCAL => +{
            host => 'localhost',
            database => 'test',
            username => 'root',
            password => "",
            tx       => 1,
        },
    },
    sharding => +{
    },
});

my $config = DBIx::Sharding->config;
my ($dsn, $user, $pass) = DBIx::Sharding->connect_info('LOCAL');

is($dsn, 'dbi:mysql:dbname=test;host=localhost', 'dsn');
is($user, 'root', 'user');
is($pass, "", 'password');
