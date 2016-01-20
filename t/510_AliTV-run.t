use strict;
use warnings;

use Test::More;
BEGIN { use_ok('AliTV') };

can_ok('AliTV', qw(run));

my $obj = new_ok('AliTV');

done_testing;