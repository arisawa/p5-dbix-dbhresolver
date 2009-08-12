use inc::Module::Install;
name 'DBIx-Sharding';
all_from 'lib/DBIx/Sharding.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
