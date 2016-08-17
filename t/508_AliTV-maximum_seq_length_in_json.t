use strict;
use warnings;

use Test::More;

BEGIN { use_ok('AliTV') };

can_ok('AliTV', qw(maximum_seq_length_in_json));

done_testing;