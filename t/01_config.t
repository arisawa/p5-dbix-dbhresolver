use strict;
use Test::More tests => 3;

use DBIx::Sharding;
use Data::Dumper;

my @config_keys = qw(host database username password);

DBIx::Sharding->config({
    USER_R => +{
        host => 'db_main_s.mbga.dena.ne.jp',
        database => 'game_user',
        username => 'game_r',
        password => 'game_r',
    },
});

my $config = DBIx::Sharding->config;
my ($dsn, $user, $pass) = DBIx::Sharding->connect_info('USER_R');

is($dsn, 'dbi:mysql:dbname=game_user;host=db_main_s.mbga.dena.ne.jp', 'dsn');
is($user, 'game_r', 'user');
is($pass, 'game_r', 'pass');

