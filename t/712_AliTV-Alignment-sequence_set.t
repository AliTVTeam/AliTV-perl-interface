use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Alignment') };

can_ok('AliTV::Alignment', qw(sequence_set));

my $obj = new_ok('AliTV::Alignment');

done_testing;
