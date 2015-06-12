#!perl

use 5.010;
use strict;
use warnings;

use Test::Exception;
use Test::More 0.98;

use Class::GenSource qw(gen_class_source_code);

my $src = gen_class_source_code(
    name => 'Foo', attributes => {bar=>{}, baz=>{}});

eval $src;
ok(!$@, "compile succeeds") or diag explain {code=>$src, error=>$@};

my $obj = Foo->new(bar=>2, baz=>3);
is($obj->bar, 2);
is($obj->baz, 3);
$obj->bar(4);
is($obj->bar, 4);
is($obj->baz(5), 5);

dies_ok { $obj->qux } "access unknown attribute -> dies";

done_testing;
