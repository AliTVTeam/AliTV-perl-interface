use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Base') };

can_ok('AliTV::Base', qw(_initialize));

done_testing;
