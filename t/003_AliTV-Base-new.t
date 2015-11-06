use strict;
use warnings;

use Test::More;
BEGIN { use_ok('AliTV::Base') };

can_ok('AliTV::Base', qw(new));

done_testing;