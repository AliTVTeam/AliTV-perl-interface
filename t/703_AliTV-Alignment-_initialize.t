use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Alignment') };

# this test is not required as it always has a _initialize method
can_ok('AliTV::Alignment', qw(_initialize));

my $obj = new_ok('AliTV::Alignment');

lives_ok { $obj->_initialize() } 'Overwritten function should avoid exception';

done_testing;
