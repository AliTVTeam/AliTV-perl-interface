use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Genome') };

# this test is not required as it always has a file method
can_ok('AliTV::Genome', qw(name));

my $obj = new_ok('AliTV::Genome');

my $name = "Testname";

is($obj->name(), '', 'Default name is empty string');

is($obj->name($name), $name, 'Set returns new name');

is($obj->name(), $name, 'Correct name is returned');

done_testing;
