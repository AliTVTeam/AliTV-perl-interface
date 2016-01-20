use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

# this test is not required as it always has a _initialize method
can_ok('AliTV', qw(_initialize));

my $obj = new_ok('AliTV');

lives_ok { $obj->_initialize() } 'Overwritten function should avoid exception';

done_testing;
