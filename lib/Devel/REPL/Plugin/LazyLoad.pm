## no critic (RequireUseStrict)
package Devel::REPL::Plugin::LazyLoad;

## use critic (RequireUseStrict)
use Devel::REPL::Plugin;

use Carp qw(croak);
use List::MoreUtils qw(any);

use namespace::clean -except => 'meta';

sub _lazy_load_exporter {
    my ( $self, $module, @functions ) = @_;

    if(any { /^:/ } @functions) {
        croak "Import tags are not suppoted";
    }

    my $package = $self->current_package;

    foreach my $function (@functions) {
        no strict 'refs';

        my $glob = \*{$package . '::' . $function};

        next if *{$glob}{'CODE'};

        *{$glob} = sub {
            my $functions = 'qw{' . join(' ', @functions) . '}';
            eval "package $package; require $module; local \$SIG{__WARN__} = sub {}; $module->import($functions);";
            goto &{$package . '::' . $function};
        };
    }
}

sub _lazy_load_oo {
    my ( $self, $module ) = @_;

    my $package;
    my $fn_name;

    if($module =~ /^(.*)::([^:]+)$/) {
        ( $package, $fn_name ) = ( $1, $2 );
    } else {
        $package = $self->current_package;
        $fn_name = $module;
    }

    my $module_path = $module;
    $module_path    =~ s{::}{/}g;
    $module_path   .= '.pm';

    no strict 'refs';
    my $glob = \*{$package . '::' . $fn_name};
    return if *{$glob}{'CODE'};

    *{$glob} = sub {
        require $module_path;
        return $module;
    };
}

sub lazy_load {
    my ( $self, $module, @functions ) = @_;

    if(@functions) {
        $self->_lazy_load_exporter($module, @functions);
    } else {
        $self->_lazy_load_oo($module);
    }
}

sub BEFORE_PLUGIN {
    my ( $repl ) = @_;

    $repl->load_plugin('Packages');
}

1;

__END__

# ABSTRACT: Lazily load packages into your REPL

=head1 SYNOPSIS

  # repl.rc
  $_REPL->load_plugin('LazyLoad');
  $_REPL->lazy_load('File::Slurp' => qw/read_file write_file/); # for
                                                                # Exporter-style
                                                                # modules
  $_REPL->lazy_load('DateTime'); # for OO-style modules

=head1 DESCRIPTION

This plugin for L<Devel::REPL> allows you to lazily load certain modules into
your REPL as you use them.  Let's say you end up using L<DateTime> math in
your REPL 50% of the time.  Put the following into your C<repl.rc>:

  $_REPL->load_plugin('LazyLoad');
  $_REPL->lazy_load('DateTime');

Now, the first time you use L<DateTime>, it will be loaded, and you shouldn't
notice a difference, apart from the loading time.  If you never use
L<DateTime> in a REPL session, it never gets loaded.

=head1 METHODS

=head2 $_REPL->lazy_load($module)

=head2 $_REPL->lazy_load($module, @import_list)

Tells the REPL to lazily load a module.  If no import list is specified,
C<$module> is treated as an "OO-style" module (ex. DateTime, where you
call methods on the class rather than use exported functions).  If an
import list is specified, each function in the import list is created in the
current package and will load C<$module> when invoked.

=head1 LIMITATIONS

=over 4

=item *

C<my $class = 'DateTime'; $class-E<gt>new> will not work.

=item *

C<DateTime::-E<gt>new> will not work.

=item *

Exported symbols that are not specified in the call to import will
not work.

=item *

Prototypes for exported functions may be messed up until they are actually imported into the REPL.

=back

=head1 SEE ALSO

L<Devel::REPL>

=begin comment

=over

=item BEFORE_PLUGIN

=back

=end comment

=cut
