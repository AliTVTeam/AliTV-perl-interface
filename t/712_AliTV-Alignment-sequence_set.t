use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Alignment') };

can_ok('AliTV::Alignment', qw(sequence_set));

my $obj = new_ok('AliTV::Alignment');

# test sequence set
my $expected_default = [];

is_deeply($obj->sequence_set(), $expected_default, 'Default value is an empty array');

done_testing;
