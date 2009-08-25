use inc::Module::Install;
name 'DBIx-Sharding';
all_from 'lib/DBIx/Sharding.pm';

requires 'Carp';
requires 'Class::Data::Inheritable';
requires 'DBI';
requires 'UNIVERSAL::require';
requires 'YAML';

build_requires 'Test::More';

auto_set_repository;

tests 't/*.t';
author_tests 'xt';

use_test_base;
auto_include;
auto_manifest;
WriteAll;
