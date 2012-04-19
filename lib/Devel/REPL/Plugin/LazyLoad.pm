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

        *{$package . '::' . $function} = sub {
            my $functions = 'qw{' . join(' ', @functions) . '}';
            eval "package $package; require $module; no warnings 'redefine'; $module->import($functions);";
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
    *{$package . '::' . $fn_name} = sub {
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

# ABSTRACT:  A short description of Devel::REPL::Plugin::LazyLoad

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=head1 SEE ALSO

=cut
