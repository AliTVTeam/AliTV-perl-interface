use strict;
use warnings;

use Test::More;
BEGIN { use_ok('AliTV::Tree') };

can_ok('AliTV::Tree', qw(new));

my $obj = new_ok('AliTV::Tree');

done_testing;