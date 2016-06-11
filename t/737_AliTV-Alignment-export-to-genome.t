use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Alignment') }

can_ok( 'AliTV::Alignment', qw(export_to_genome) );

done_testing;
