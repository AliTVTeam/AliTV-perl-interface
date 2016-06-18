use strict;
use warnings;

use Test::More;
BEGIN { use_ok('AliTV::Base') };
local *AliTV::Base::_initialize = sub {};

can_ok('AliTV::Base', qw(DESTROY));

done_testing;