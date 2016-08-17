use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

can_ok('AliTV', qw(maximum_seq_length_in_json));

my $obj = new_ok('AliTV');

lives_ok { $obj->maximum_seq_length_in_json(12345); } 'No exception if parameter is an unsigned integer value';

# recreate our object
$obj = new_ok('AliTV');

my $expected_default = 1000000;
is($obj->maximum_seq_length_in_json(), $expected_default, 'Default value will be returned');

done_testing;