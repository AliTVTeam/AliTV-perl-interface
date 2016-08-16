use strict;
use warnings;

use Test::More;
use Test::Exception;
use File::Which;
use File::Temp;

BEGIN { use_ok('AliTV::Tree') }

can_ok( 'AliTV::Tree', qw(_ladderize) );

my $obj = new_ok('AliTV::Tree');

done_testing;