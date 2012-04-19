use strict;
use warnings;
use lib 't/lib';

use Devel::REPL;
use Test::More tests => 10;
use Test::NoWarnings;

NO_LAZY_LOADING: {
    my $repl = Devel::REPL->new( term => {} );

    my ( $result ) = $repl->eval('OOModule->frobnicate');
    isa_ok $result, 'Devel::REPL::Error';

    ( $result ) = $repl->eval('foo_bar()');
    isa_ok $result, 'Devel::REPL::Error';
}

LAZY_LOAD_PLUGIN_NO_LAZY_LOADING: {
    my $repl = Devel::REPL->new( term => {} );
    $repl->load_plugin('LazyLoad');

    my ( $result ) = $repl->eval('OOModule->frobnicate');
    isa_ok $result, 'Devel::REPL::Error';

    ( $result ) = $repl->eval('foo_bar()');
    isa_ok $result, 'Devel::REPL::Error';
}

LAZY_LOAD_OO_MODULE: {
    my $repl = Devel::REPL->new( term => {} );
    $repl->load_plugin('LazyLoad');
    $repl->lazy_load('OOModule');

    my ( $result ) = $repl->eval('OOModule->frobnicate');
    is $result, 17;

    ( $result ) = $repl->eval('foo_bar()');
    isa_ok $result, 'Devel::REPL::Error';
}

LAZY_LOAD_FUNC_MODULE: {
    my $repl = Devel::REPL->new( term => {} );
    $repl->load_plugin('LazyLoad');
    $repl->lazy_load('OOModule');
    $repl->lazy_load(ExportingModule => qw{foo_bar});

    my ( $result ) = $repl->eval('OOModule->frobnicate');
    is $result, 17;

    ( $result ) = $repl->eval('foo_bar()');
    is $result, 18;
}

LAZY_LOAD_MULTI_LEVEL_OO_PACKAGE: {
    my $repl = Devel::REPL->new( term => {} );
    $repl->load_plugin('LazyLoad');
    $repl->lazy_load('OOModule::Nested::Package');

    my ( $result ) = $repl->eval('OOModule::Nested::Package->invoke');
    is $result, 19;
}
