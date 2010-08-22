use inc::Module::Install;
name 'DBIx-DBHResolver';
all_from 'lib/DBIx/DBHResolver.pm';

requires 'parent';
requires 'Carp';
requires 'Class::Accessor::Fast';
requires 'DBI';
requires 'Try::Tiny';
requires 'UNIVERSAL::require';
requires 'YAML';

test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'Test::LoadAllModules';
test_requires 'Test::Requires';

auto_set_repository;

tests 't/*.t';
author_tests 'xt';

use_test_base;
auto_include;
# auto_manifest;
WriteAll;
