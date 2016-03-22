use strict;
use warnings;

use Test::More;
BEGIN { use_ok('AliTV::Alignment') };
local *AliTV::Alignment::_initialize = sub {};

can_ok('AliTV::Alignment', qw(new));

my $obj = new_ok('AliTV::Alignment');

done_testing;