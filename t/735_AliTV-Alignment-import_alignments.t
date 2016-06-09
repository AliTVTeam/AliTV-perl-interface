use strict;
use warnings;

use Test::More;
use Test::Exception;
local *AliTV::Alignment::_check = sub {};

BEGIN { use_ok('AliTV::Alignment') }

can_ok( 'AliTV::Alignment', qw(import_alignments) );

done_testing;
