use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Seq') };

# this test is not required as it always has a _initialize method
can_ok('AliTV::Seq', qw(_initialize));

lives_ok { AliTV::Seq->_initialize() } 'Overwritten function should avoid exception';

done_testing;
