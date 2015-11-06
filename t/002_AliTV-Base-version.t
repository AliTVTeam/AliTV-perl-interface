use strict;
use warnings;

use Test::More;
BEGIN { use_ok('AliTV::Base') };

ok(defined $AliTV::Base::VERSION, "A version variable is defined");

done_testing;