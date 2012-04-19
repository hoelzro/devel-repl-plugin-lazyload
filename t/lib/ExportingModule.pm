package ExportingModule;

use strict;
use warnings;
use parent 'Exporter';

our @EXPORT = qw(foo_bar);

sub foo_bar {
    return 18;
}

1;
