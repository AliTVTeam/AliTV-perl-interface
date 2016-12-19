use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Alignment') };

can_ok('AliTV::Alignment', qw(_check_if_maf_fix_is_required));

my $obj = new_ok('AliTV::Alignment');

done_testing;
