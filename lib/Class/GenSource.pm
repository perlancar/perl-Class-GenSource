package Class::GenSource;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(gen_class_source_code);

our %SPEC;

my $re_ident = qr/\A[A-Za-z_][A-Za-z0-9_]*(::[A-Za-z_][A-Za-z0-9_]*)*\z/;

$SPEC{gen_class_source_code} = {
    v => 1.1,
    summary => 'Generate Perl source code to declare a class',
    description => <<'_',

_
    args => {
        name => {
            schema  => ['str*', match=>$re_ident],
            req => 1,
        },
        parent => {
            schema  => ['str*', match=>$re_ident],
        },
        attributes => {
            schema  => ['hash*', match=>$re_ident],
            default => {},
        },
        variant => {
            schema => ['str*', in=>[qw/classic Mo Moo Moose/]],
            default => 'classic',
        },
    },
    result_naked => 1,
};
sub gen_class_source_code {
    my %args = @_;

    # XXX schema
    my $variant = $args{variant} // 'classic';

    my @res;

    push @res, "package $args{name};\n";
    if ($variant =~ /^Mo/) {
        push @res, "use $variant;\n";
    }

    if ($args{parent}) {
        if ($variant =~ /^Mo/) {
            push @res, "extends '$args{parent}';\n";
        } else {
            push @res, "use parent qw(", $args{parent}, ");\n";
        }
    }

    if ($variant eq 'classic') {
        push @res, q[sub new { my $class = shift; bless {@_}, $class; }], "\n";
    }

    my $attrs = $args{attributes} // {};
    for my $name (sort keys %$attrs) {
        if ($variant =~ /^Mo/) {
            push @res, "has $name => (is=>'rw');\n";
        } else {
            push @res, "sub $name {}\n";
        }
    }

    join("", @res);
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use Class::GenSource qw(gen_class_source_code);

 say gen_class_source_code(
     name => 'My::Class',
     attributes => {
         foo => {},
         bar => {},
         baz => {},
     },
 );

Will print something like:

 package My::Class;

 sub new { my $class = shift; bless {@_}, $class }
 sub foo {}
 sub bar {}
 sub baz {}

Another example (generating L<Moo>-based class):

 say gen_class_source_code(
     name => 'My::Class',
     attributes => {
         foo => {},
         bar => {},
         baz => {},
     },
     variant => 'Moo',
 );

will print something like:

 package My::Class;
 use Moo;
 has foo => (is=>'rw');
 has bar => (is=>'rw');
 has baz => (is=>'rw');


=head1 DESCRIPTION
