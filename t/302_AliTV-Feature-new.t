use strict;
use warnings;

use Test::More;

BEGIN { use_ok('AliTV::Feature') };

can_ok('AliTV::Feature', qw(new));

my $obj = new_ok('AliTV::Feature');

done_testing;