package REPLTest;

use strict;
use warnings;
use parent 'Exporter';

use Devel::REPL;
use Test::More;

our @EXPORT = qw(test_repl);

sub test_repl (&) {
    my ( $action ) = @_;

    my $repl = Devel::REPL->new(term => {});
    return $action->($repl);
}

1;
