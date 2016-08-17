use strict;
use warnings;

use Test::More;

BEGIN { use_ok('AliTV') };

can_ok('AliTV', qw(_calculate_tick_distance ticks_every_num_of_bases));

done_testing;