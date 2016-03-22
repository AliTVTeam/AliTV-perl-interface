use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

can_ok('AliTV', qw(run));

my $chloroset = 'data/chloroset/input.yml';
my $obj = new_ok('AliTV', ["-file" => $chloroset]);

$obj->run();

done_testing;
