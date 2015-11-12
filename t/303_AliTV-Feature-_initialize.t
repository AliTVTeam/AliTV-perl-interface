use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Feature') };

# this test is not required as it always has a _initialize method
can_ok('AliTV::Feature', qw(_initialize));

done_testing;
