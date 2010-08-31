package DBIx::DBHResolver;

use strict;
use warnings;
use parent qw(Class::Accessor::Fast);
use Carp;
use Config::Any;
use Data::Util qw(is_value is_array_ref is_hash_ref is_instance is_invocant);
use DBI;
use Hash::Merge::Simple qw(merge);
use Try::Tiny;
use UNIVERSAL::require;

use DBIx::DBHResolver::Strategy::Key;
use DBIx::DBHResolver::Strategy::List;
use DBIx::DBHResolver::Strategy::Range;

our $VERSION                   = '0.12';
our $CONFIG                    = +{};
our $DBI                       = 'DBI';
our $DBI_CONNECT_METHOD        = 'connect';
our $DBI_CONNECT_CACHED_METHOD = 'connect_cached';

__PACKAGE__->mk_accessors(qw/_config/);

sub new {
    shift->SUPER::new( +{ _config => +{} } );
}

sub config {
    my ( $proto, $config ) = @_;

    if ( is_instance( $proto, 'DBIx::DBHResolver' ) ) {
        return $proto->_config unless defined $config;
        $proto->_config($config);
    }
    else {
        return $CONFIG unless defined $config;
        $CONFIG = $config;
    }
}

sub load {
    my ( $proto, @files ) = @_;
    for ( @files ) {
	croak $! unless ( -f $_ && -r $_ );
    }
    my $config;
    try {
	$config = Config::Any->load_files( +{ files => \@files, use_ext => 1, flatten_to_hash => 1, } );
	$config = merge( @$config{@files} );
    }
    catch {
	croak $_;
    };
    $proto->config( $config );
}

sub connect {
    my ( $proto, $cluster_or_node, $args ) = @_;
    my $dbh = $DBI->$DBI_CONNECT_METHOD(
        @{ $proto->connect_info( $cluster_or_node, $args ) }
          {qw/dsn user password attrs/} )
      or croak($DBI::errstr);
    return $dbh;
}

sub connect_cached {
    my ( $proto, $cluster_or_node, $args ) = @_;
    my $dbh = $DBI->$DBI_CONNECT_CACHED_METHOD(
        @{ $proto->connect_info( $cluster_or_node, $args ) }
          {qw/dsn user password attrs/} )
      or croak($DBI::errstr);
    return $dbh;
}

sub disconnect_all {
    my ($proto) = @_;

    my %drivers = DBI->installed_drivers;
    for my $drh ( values %drivers ) {
        for my $dbh ( @{ $drh->{ChildHandles} } ) {
            eval { $dbh->disconnect; };
        }
    }
}

sub connect_info {
    my ( $proto, $cluster_or_node, $args ) = @_;

    if ( $proto->is_node($cluster_or_node) ) {
        croak sprintf( 'not found connect_info: %s', $cluster_or_node )
          unless ( exists $proto->config->{connect_info}{$cluster_or_node} );
        my $connect_info = $proto->config->{connect_info}{$cluster_or_node};
        if ( ref $connect_info eq 'HASH' ) {
            return $connect_info;
        }
        else {
            return $proto->connect_info($connect_info);
        }
    }
    elsif ( $proto->is_cluster($cluster_or_node) ) {
        if ( is_hash_ref $args ) {
            croak q|args has not 'strategy' field| unless $args->{strategy};
            my $strategy_class =
              $proto->_resolve_namespace( $args->{strategy} );
            return $proto->_ensure_class_loaded($strategy_class)
              ->connect_info( $proto, $cluster_or_node, $args );
        }
        else {
            my $cluster_info = $proto->cluster_info($cluster_or_node);
            if ( is_array_ref $cluster_info ) {
                return DBIx::DBHResolver::Strategy::Key->connect_info(
                    $proto,
                    $cluster_or_node,
                    +{
                        strategy => 'Key',
                        nodes    => $cluster_info,
                        key      => $args,
                    }
                );
            }
            elsif ( is_hash_ref $cluster_info ) {
                my $strategy_class =
                  $proto->_resolve_namespace( $cluster_info->{strategy} );
                return $proto->_ensure_class_loaded($strategy_class)
                  ->connect_info( $proto, $cluster_or_node,
                    +{ %$cluster_info, key => $args, } );
            }
        }
    }
    else {
        croak sprintf( '%s is not defined', $cluster_or_node );
    }
}

sub cluster_info {
    my ( $proto, $cluster ) = @_;
    $proto->config->{clusters}{$cluster};
}

sub clusters {
    my ( $proto, $cluster ) = @_;
    my $cluster_info = $proto->cluster_info($cluster);
    my @nodes =
      is_array_ref($cluster_info)
      ? @$cluster_info
      : @{ $cluster_info->{nodes} };
    wantarray ? @nodes : \@nodes;
}

{
    no warnings;
    *cluster = \&clusters;
}

sub is_cluster {
    my ( $proto, $cluster ) = @_;
    exists $proto->config->{clusters}{$cluster} ? 1 : 0;
}

sub is_node {
    my ( $proto, $node ) = @_;
    exists $proto->config->{connect_info}{$node} ? 1 : 0;
}

sub _ensure_class_loaded {
    my ( $proto, $class_name ) = @_;
    unless ( is_invocant $class_name ) {
        try {
            $class_name->require;
        }
        catch {
            croak $_;
        };
    }
    $class_name;
}

sub _resolve_namespace {
    my ( $proto, $class_name ) = @_;
    $class_name = 'Key'
      if ( defined $class_name && $class_name eq 'Remainder' );
    $class_name =
        $class_name =~ /^\+(.+)$/
      ? $1
      : join( '::', ( __PACKAGE__, 'Strategy', $class_name ) );
    $class_name;
}

1;

=head1 NAME

DBIx::DBHResolver - Resolve database connection on the environment has many database servers.

=head1 SYNOPSIS

  use DBIx::DBHResolver;

  my $r = DBIx::DBHResolver->new;
  $r->config(+{
    connect_info => +{
      main_master => +{
        dsn => 'dbi:mysql:dbname=main;host=localhost',
        user => 'master_user', password => '',
        attrs => +{ RaiseError => 1, AutoCommit => 0, },
      },
      main_slave => +{
        dsn => 'dbi:mysql:dbname=main;host=localhost',
        user => 'slave_user', password => '',
        attrs => +{ RaiseError => 1, AutoCommit => 1, },
      }
    },
  });

  my $dbh_master = $r->connect('main_master');
  $dbh_master->do( 'UPDATE people SET ...', undef, ... );

  my $dbh_slave = $r->connect('main_slave');
  my $people = $dbh_slave->selectrow_hashref( 'SELECT * FROM people WHERE id = ?', undef, 20 );

=head1 DESCRIPTION

DBIx::DBHResolver resolves database connection on the environment has many database servers.
The resolution algorithm is extensible and pluggable, because of this you can make custom strategy module easily.

This module can retrieve L<DBI>'s database handle object or connection information (data source, user, credential...) by labeled name
and treat same cluster consists many nodes as one labeled name, choose fetching strategy.

DBIx::DBHResolver is able to use as instance or static class.

=head2 USING STRATEGY, MAKING CUSTOM STRATEGY

See L<DBIx::DBHResolver::Strategy::Key>.

=head1 METHODS

=head2 new()

Create DBIx::DBHResolver instance.

=head2 load( $yaml_file_path )

Load config file formatted yaml. 

=head2 config( \%config )

Load config. Example config (perl hash reference format):

  +{
    clusters => +{
      diary_master => [qw/diary001_master diary002_master/],
      people_master => [qw/people001_master people002_master people003_master people004_master/]
    },
    connect_info => +{
      diary001_master => +{
        dsn => 'dbi:driverName:...',
        user => 'root', password => '', attrs => +{},
      },
      diary002_master => +{ ... },
      ...
    },
  }

=head2 connect( $cluster_or_node, \%args )

Retrieve database handle. See below about \%args details.

=over

=item strategy

Optional parameter. Specify suffix of strategy module name. Default strategy module is prefixed 'DBIx::DBHResolver::Strategy::'.
If you want to make custom strategy that is not started of 'DBIx::DBHResolver::Strategy::', then add prefix '+' at the beginning of the module name, such as '+MyApp::Strategy::Custom'.

=item key

Optional parameter. Strategy module uses hint choosing node.

=back

=head2 connect_cached($cluster_or_node, \%args)

Retrieve database handle from own cache, if not exists cache then using DBI::connect(). \%args is same as connect().

=head2 connect_info($cluster_or_node, \%args)

Retrieve connection info as HASHREF. \%args is same as connect().

=head2 disconnect_all()

Disconnect all cached database handles.

=head2 cluster_info($cluster)

Return cluster info hash ref.

=head2 clusters($cluster)

Retrieve cluster member node names as Array.

  my $r = DBIx::DBHResolver->new;
  $r->config(+{ ... });
  my $cluster_or_node = 'activities_master';
  if ( $r->is_cluster($cluster_or_node) ) {
    for ($r->cluster( $cluster_or_node )) {
      process_activities_node($_);
    }
  }
  else {
    process_activities_node($cluster_or_node);
  }

=head2 is_cluster($cluster)

Return boolean value which cluster or not given name.

=head2 is_node($node)

Return boolean value which node or not given name.

=head1 GLOBAL VARIABLES

=head2 $CONFIG

Stored config on using class module.

=head2 $DBI

DBI module name, default 'DBI'. If you want to use custom L<DBI> sub class, then you must override this variable.

=head2 $DBI_CONNECT_METHOD

DBI connect method name, default 'connect';

If you want to use L<DBIx::Connector> instead of L<DBI>, then:

  use DBIx::Connector;
  use DBIx::DBHResolver;

  $DBIx::DBHResolver::DBI = 'DBIx::Connector';
  $DBIx::DBHResolver::DBI_CONNECT_METHOD = 'new';
  $DBIx::DBHResolver::DBI_CONNECT_CACHED_METHOD = 'new';

  my $r = DBIx::DBHResolver->new;
  $r->config(+{...});

  $r->connect('main_master')->txn(
    fixup => sub {
      my $dbh = shift;
      ...
    }
  );

=head2 $DBI_CONNECT_CACHED_METHOD

DBI connect method name, default 'connect_cached';

=head1 AUTHOR

=over

=item Kosuke Arisawa E<lt>arisawa@gmail.comE<gt>

=item Toru Yamaguchi E<lt>zigorou@cpan.orgE<gt>

=back

=head1 SEE ALSO

=over

=item L<DBI>

=back

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
