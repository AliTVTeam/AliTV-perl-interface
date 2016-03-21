use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

# this test was introduced, due to the fact, that I tried to reread
# the DATA section of the AliTV.pm. To avoid this problem again, I
# added a test which test if multiple calls of get_default_settings()
# will produce the same result.

# this test is not required as it always has a file method
can_ok('AliTV', qw(_make_and_set_uniq_seq_names));

my $obj = new_ok('AliTV');

done_testing;
