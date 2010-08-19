use strict;
use warnings;

use Test::More;
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
            dsn      => 'dbi:mysql:dbname=test;host=slave2',
            user     => 'root',
            password => "",
        },
    },
    clusters => +{
        MASTER => [qw(MASTER1 MASTER2)],
        SLAVE  => [qw(SLAVE1 SLAVE2 SLAVE3)],
    },
};

sub test_connect_info {
    my %specs = @_;
    my ( $desc, $resolver, $node, $node_args, $expects ) =
      @specs{qw/desc resolver node node_args expects/};
    my $conn_info = $resolver->connect_info( $node, $node_args );
    is_deeply( $conn_info, $expects, $desc );
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
        desc      => 'using remainder strategy (nodes: 2, key: 6)',
        resolver  => $resolver,
        node      => 'MASTER',
        node_args => +{ strategy => 'Remainder', key => 6, },
        expects   => $TEST_CONFIG->{connect_info}{MASTER1},
    );

    test_connect_info(
        desc      => 'using remainder strategy (nodes: 2, key: 7)',
        resolver  => $resolver,
        node      => 'MASTER',
        node_args => +{ strategy => 'Remainder', key => 7, },
        expects   => $TEST_CONFIG->{connect_info}{MASTER2},
    );

    test_connect_info(
        desc      => 'using remainder strategy (nodes:3, key: 6)',
        resolver  => $resolver,
        node      => 'SLAVE',
        node_args => +{ strategy => 'Remainder', key => 6, },
        expects   => $TEST_CONFIG->{connect_info}{SLAVE1},
    );

    test_connect_info(
        desc      => 'using remainder strategy (nodes:3, key: 7)',
        resolver  => $resolver,
        node      => 'SLAVE',
        node_args => +{ strategy => 'Remainder', key => 7, },
        expects   => $TEST_CONFIG->{connect_info}{SLAVE2},
    );

    test_connect_info(
        desc      => 'using remainder strategy (nodes:3, key: 8)',
        resolver  => $resolver,
        node      => 'SLAVE',
        node_args => +{ strategy => 'Remainder', key => 8, },
        expects   => $TEST_CONFIG->{connect_info}{SLAVE3},
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

subtest 'using connect_info as static sub class, store config into parent class' => sub {
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

__END__

{
    my $info = DBIx::DBHResolver->connect_info('LOCAL');
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
    my $info = DBIx::DBHResolver->connect_info(
        'MASTER',
        +{ strategy => 'Remainder', key => 6 },
    );
    is_deeply(
        {
            dsn => 'dbi:mysql:dbname=test;host=master1',
            user => 'root',
            password => "",
        },
        $info,
        "DBIx::DBHResolver::Strategy::Remainder - 1",
    );
}

{
    my $info = DBIx::DBHResolver->connect_info(
        'SLAVE',
        +{ strategy => 'Remainder', key => 7 },
    );
    is_deeply(
        {
            dsn => 'dbi:mysql:dbname=test;host=slave2',
            user => 'root',
            password => "",
        },
        $info,
        "DBIx::DBHResolver::Strategy::Remainder - 2",
    );
}
