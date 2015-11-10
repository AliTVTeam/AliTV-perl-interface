use strict;
use warnings;

use Test::More;

BEGIN { use_ok('AliTV::Seq') };

can_ok('AliTV::Seq', qw(new));

my $obj = new_ok('AliTV::Seq');

done_testing;