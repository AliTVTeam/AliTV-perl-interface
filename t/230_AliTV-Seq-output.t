use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Seq') };

can_ok('AliTV::Seq', qw(output));

done_testing;
