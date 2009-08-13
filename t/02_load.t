use strict;
use Test::More tests => 3;

use FindBin;
use DBIx::Sharding;
use Data::Dumper;

DBIx::Sharding->load("$FindBin::Bin/db.conf.yaml");

my ($dsn, $user, $pass) = DBIx::Sharding->connect_info('ADMIN_BAK');

is($dsn, 'dbi:mysql:dbname=game_admin;host=db_admin_b.mbga.dena.ne.jp', 'dsn');
is($user, 'game_r', 'user');
is($pass, undef, 'password');
