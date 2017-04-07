use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Alignment') };

can_ok('AliTV::Alignment', qw(_check_if_maf_fix_is_required));

my $obj = new_ok('AliTV::Alignment');

lives_ok { AliTV::Alignment->_check_if_maf_fix_is_required(); } '_check_if_maf_fix_is_required() did not die and therefore returned 0 or 1';

done_testing;
