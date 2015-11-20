use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Warnings;

BEGIN { use_ok('AliTV::Tree') }

can_ok( 'AliTV::Tree', qw(check_4_leaf_nodes) );

my $obj = new_ok('AliTV::Tree');

done_testing;
