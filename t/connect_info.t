use strict;
use warnings;

use Test::More;
use Test::Exception;
use DBIx::DBHResolver;

our $TEST_CONFIG = +{
    connect_info => +{
        LOCAL => +{
            dsn      => 'dbi:mysql:dbname=test;host=localhost',
            user     => 'root',
            password => "",
        },
        MASTER1 => +{
            dsn      => 'dbi:mysql:dbname=test;host=master1',
            user     => 'root',
            password => "",
        },
        MASTER2 => +{
            dsn      => 'dbi:mysql:dbname=test;host=master2',
            user     => 'root',
            password => "",
        },
        SLAVE1 => +{
            dsn      => 'dbi:mysql:dbname=test;host=slave1',
            user     => 'root',
            password => "",
        },
        SLAVE2 => +{
            dsn      => 'dbi:mysql:dbname=test;host=slave2',
            user     => 'root',
            password => "",
        },
        SLAVE3 => +{
            dsn      => 'dbi:mysql:dbname=test;host=slave3',
            user     => 'root',
            password => "",
        },
        SLAVE4 => +{
            dsn      => 'dbi:mysql:dbname=test;host=slave4',
            user     => 'root',
            password => "",
        },
        SLAVE5 => +{
            dsn      => 'dbi:mysql:dbname=test;host=slave5',
            user     => 'root',
            password => "",
        },
        SLAVE6 => +{
            dsn      => 'dbi:mysql:dbname=test;host=slave6',
            user     => 'root',
            password => "",
        },
        ALIAS1 => 'SLAVE1',
        ALIAS2 => 'SLAVE2',
        ALIAS3 => 'SLAVE3',
        ALIAS4 => 'SLAVE4',
        ALIAS5 => 'SLAVE5',
        ALIAS6 => 'SLAVE6',
    },
    clusters => +{
        MASTER         => [qw(MASTER1 MASTER2)],
        SLAVE          => [qw(SLAVE1 SLAVE2 SLAVE3)],
        MASTER_CLUSTER => +{
            strategy => 'Key',
            nodes    => [qw(MASTER1 MASTER2)]
        },
        SLAVE_CLUSTER1 => +{
            strategy => 'Key',
            nodes    => [qw(SLAVE1 SLAVE2)]
        },
        SLAVE_CLUSTER2 => +{
            strategy => 'Key',
            nodes    => [qw(SLAVE3 SLAVE4)]
        },
        SLAVE_CLUSTER3 => +{
            strategy => 'Key',
            nodes    => [qw(SLAVE5 SLAVE6)]
        },
        SLAVE_CLUSTER => +{
            strategy => 'Key',
            nodes    => [qw(SLAVE_CLUSTER1 SLAVE_CLUSTER2 SLAVE_CLUSTER3)]
        },
        ALIAS_CLUSTER1 => +{
            strategy => 'Key',
            nodes    => [qw(ALIAS1 ALIAS2)]
        },
        ALIAS_CLUSTER2 => +{
            strategy => 'Key',
            nodes    => [qw(ALIAS3 ALIAS4)]
        },
        ALIAS_CLUSTER3 => +{
            strategy => 'Key',
            nodes    => [qw(ALIAS5 ALIAS6)]
        },
        ALIAS_CLUSTER => +{
            strategy => 'Key',
            nodes    => [qw(ALIAS_CLUSTER1 ALIAS_CLUSTER2 ALIAS_CLUSTER3)]
        },
    },
};

sub test_connect_info {
    my %specs = @_;
    my ( $desc, $resolver, $node, $node_args, $expects, $is_lives ) =
      @specs{qw/desc resolver node node_args expects is_lives/};

    $is_lives = 1 unless defined $is_lives;

    my $conn_info;
    if ($is_lives) {
        lives_ok {
            $conn_info = $resolver->connect_info( $node, $node_args );
        }
        'connect_info lives ok';
        is_deeply( $conn_info, $expects, $desc );
    }
    else {
        dies_ok {
            $conn_info = $resolver->connect_info( $node, $node_args );
        }
        'connect_info dies ok';
    }
}

sub run_all_tests {
    my $resolver = shift;

    test_connect_info(
        desc     => 'single node',
        resolver => $resolver,
        node     => 'LOCAL',
        expects  => $TEST_CONFIG->{connect_info}{LOCAL},
    );

    test_connect_info(
        desc      => 'using key strategy (nodes: 2, key: 6)',
        resolver  => $resolver,
        node      => 'MASTER',
        node_args => +{ strategy => 'Key', key => 6, },
        expects   => $TEST_CONFIG->{connect_info}{MASTER1},
    );

    test_connect_info(
        desc      => 'using key strategy (nodes: 2, key: 7)',
        resolver  => $resolver,
        node      => 'MASTER',
        node_args => +{ strategy => 'Key', key => 7, },
        expects   => $TEST_CONFIG->{connect_info}{MASTER2},
    );

    test_connect_info(
        desc      => 'using key strategy with scalar args (nodes: 2, key: 6)',
        resolver  => $resolver,
        node      => 'MASTER',
        node_args => 6,
        expects   => $TEST_CONFIG->{connect_info}{MASTER1},
    );

    test_connect_info(
        desc      => 'using key strategy with scalar args (nodes: 2, key: 7)',
        resolver  => $resolver,
        node      => 'MASTER',
        node_args => 7,
        expects   => $TEST_CONFIG->{connect_info}{MASTER2},
    );

    test_connect_info(
        desc     => 'using key strategy with array ref args (nodes: 2, key: 6)',
        resolver => $resolver,
        node     => 'MASTER',
        node_args => [6],
        expects   => $TEST_CONFIG->{connect_info}{MASTER1},
    );

    test_connect_info(
        desc     => 'using key strategy with array ref args (nodes: 2, key: 7)',
        resolver => $resolver,
        node     => 'MASTER',
        node_args => [7],
        expects   => $TEST_CONFIG->{connect_info}{MASTER2},
    );

    test_connect_info(
        desc      => 'using key strategy (nodes:3, key: 6)',
        resolver  => $resolver,
        node      => 'SLAVE',
        node_args => +{ strategy => 'Key', key => 6, },
        expects   => $TEST_CONFIG->{connect_info}{SLAVE1},
    );

    test_connect_info(
        desc      => 'using key strategy (nodes:3, key: 7)',
        resolver  => $resolver,
        node      => 'SLAVE',
        node_args => +{ strategy => 'Key', key => 7, },
        expects   => $TEST_CONFIG->{connect_info}{SLAVE2},
    );

    test_connect_info(
        desc      => 'using key strategy (nodes:3, key: 8)',
        resolver  => $resolver,
        node      => 'SLAVE',
        node_args => +{ strategy => 'Key', key => 8, },
        expects   => $TEST_CONFIG->{connect_info}{SLAVE3},
    );

    test_connect_info(
        desc     => 'alias node 1',
        resolver => $resolver,
        node     => 'ALIAS1',
        expects  => $TEST_CONFIG->{connect_info}{SLAVE1},
    );

    test_connect_info(
        desc     => 'alias node 2',
        resolver => $resolver,
        node     => 'ALIAS2',
        expects  => $TEST_CONFIG->{connect_info}{SLAVE2},
    );

    test_connect_info(
        desc     => 'alias node 3',
        resolver => $resolver,
        node     => 'ALIAS3',
        expects  => $TEST_CONFIG->{connect_info}{SLAVE3},
    );

    test_connect_info(
        desc      => 'using config with scalar key (MASTER_CLUSTER, key: 8)',
        resolver  => $resolver,
        node      => 'MASTER_CLUSTER',
        node_args => 8,
        expects   => $TEST_CONFIG->{connect_info}{MASTER1},
    );

    test_connect_info(
        desc      => 'using config with scalar key (MASTER_CLUSTER, key: 9)',
        resolver  => $resolver,
        node      => 'MASTER_CLUSTER',
        node_args => 9,
        expects   => $TEST_CONFIG->{connect_info}{MASTER2},
    );

    test_connect_info(
        desc      => 'using config with array ref key (MASTER_CLUSTER, key: 8)',
        resolver  => $resolver,
        node      => 'MASTER_CLUSTER',
        node_args => [8],
        expects   => $TEST_CONFIG->{connect_info}{MASTER1},
    );

    test_connect_info(
        desc      => 'using config with array ref key (MASTER_CLUSTER, key: 9)',
        resolver  => $resolver,
        node      => 'MASTER_CLUSTER',
        node_args => [9],
        expects   => $TEST_CONFIG->{connect_info}{MASTER2},
    );

    test_connect_info(
        desc =>
          'using config with array ref key (SLAVE_CLUSTER, key: [ 3, 10 ])',
        resolver  => $resolver,
        node      => 'SLAVE_CLUSTER',
        node_args => [ 3, 10 ],
        expects   => $TEST_CONFIG->{connect_info}{SLAVE1},
    );

    test_connect_info(
        desc =>
          'using config with array ref key (SLAVE_CLUSTER, key: [ 3, 11 ])',
        resolver  => $resolver,
        node      => 'SLAVE_CLUSTER',
        node_args => [ 3, 11 ],
        expects   => $TEST_CONFIG->{connect_info}{SLAVE2},
    );

    test_connect_info(
        desc =>
          'using config with array ref key (SLAVE_CLUSTER, key: [ 4, 10 ])',
        resolver  => $resolver,
        node      => 'SLAVE_CLUSTER',
        node_args => [ 4, 10 ],
        expects   => $TEST_CONFIG->{connect_info}{SLAVE3},
    );

    test_connect_info(
        desc =>
          'using config with array ref key (SLAVE_CLUSTER, key: [ 4, 11 ])',
        resolver  => $resolver,
        node      => 'SLAVE_CLUSTER',
        node_args => [ 4, 11 ],
        expects   => $TEST_CONFIG->{connect_info}{SLAVE4},
    );

    test_connect_info(
        desc =>
          'using config with array ref key (SLAVE_CLUSTER, key: [ 5, 10 ])',
        resolver  => $resolver,
        node      => 'SLAVE_CLUSTER',
        node_args => [ 5, 10 ],
        expects   => $TEST_CONFIG->{connect_info}{SLAVE5},
    );

    test_connect_info(
        desc =>
          'using config with array ref key (SLAVE_CLUSTER, key: [ 5, 11 ])',
        resolver  => $resolver,
        node      => 'SLAVE_CLUSTER',
        node_args => [ 5, 11 ],
        expects   => $TEST_CONFIG->{connect_info}{SLAVE6},
    );

    test_connect_info(
        desc =>
          'using config with array ref key (ALIAS_CLUSTER, key: [ 3, 10 ])',
        resolver  => $resolver,
        node      => 'ALIAS_CLUSTER',
        node_args => [ 3, 10 ],
        expects   => $TEST_CONFIG->{connect_info}{SLAVE1},
    );

    test_connect_info(
        desc =>
          'using config with array ref key (ALIAS_CLUSTER, key: [ 3, 11 ])',
        resolver  => $resolver,
        node      => 'ALIAS_CLUSTER',
        node_args => [ 3, 11 ],
        expects   => $TEST_CONFIG->{connect_info}{SLAVE2},
    );

    test_connect_info(
        desc =>
          'using config with array ref key (ALIAS_CLUSTER, key: [ 4, 10 ])',
        resolver  => $resolver,
        node      => 'ALIAS_CLUSTER',
        node_args => [ 4, 10 ],
        expects   => $TEST_CONFIG->{connect_info}{SLAVE3},
    );

    test_connect_info(
        desc =>
          'using config with array ref key (ALIAS_CLUSTER, key: [ 4, 11 ])',
        resolver  => $resolver,
        node      => 'ALIAS_CLUSTER',
        node_args => [ 4, 11 ],
        expects   => $TEST_CONFIG->{connect_info}{SLAVE4},
    );

    test_connect_info(
        desc =>
          'using config with array ref key (ALIAS_CLUSTER, key: [ 5, 10 ])',
        resolver  => $resolver,
        node      => 'ALIAS_CLUSTER',
        node_args => [ 5, 10 ],
        expects   => $TEST_CONFIG->{connect_info}{SLAVE5},
    );

    test_connect_info(
        desc =>
          'using config with array ref key (ALIAS_CLUSTER, key: [ 5, 11 ])',
        resolver  => $resolver,
        node      => 'ALIAS_CLUSTER',
        node_args => [ 5, 11 ],
        expects   => $TEST_CONFIG->{connect_info}{SLAVE6},
    );
}

subtest 'using connect_info as static class' => sub {
    $DBIx::DBHResolver::CONFIG = +{};
    my $resolver = 'DBIx::DBHResolver';
    $resolver->config($TEST_CONFIG);
    run_all_tests($resolver);
    done_testing;
};

subtest 'using connect_info as static sub class' => sub {
    $DBIx::DBHResolver::CONFIG = +{};

    do {

        package My::Resolver;
        use parent qw(DBIx::DBHResolver);
    };

    my $resolver = 'My::Resolver';
    $resolver->config($TEST_CONFIG);
    run_all_tests($resolver);
    done_testing;
};

subtest
  'using connect_info as static sub class, store config into parent class' =>
  sub {
    $DBIx::DBHResolver::CONFIG = +{};

    do {

        package My::Resolver;
        use parent qw(DBIx::DBHResolver);
    };

    my $resolver = 'My::Resolver';
    DBIx::DBHResolver->config($TEST_CONFIG);
    run_all_tests($resolver);
    done_testing;
  };

subtest 'using connect_info as instance' => sub {
    $DBIx::DBHResolver::CONFIG = +{};
    my $resolver = DBIx::DBHResolver->new;
    $resolver->config($TEST_CONFIG);
    run_all_tests($resolver);
    done_testing;
};

subtest 'using connect_info as instance of sub class' => sub {
    $DBIx::DBHResolver::CONFIG = +{};

    do {

        package My::Resolver2;
        use parent qw(DBIx::DBHResolver);
    };

    my $resolver = My::Resolver2->new;
    $resolver->config($TEST_CONFIG);
    run_all_tests($resolver);
    done_testing;
};

done_testing;
