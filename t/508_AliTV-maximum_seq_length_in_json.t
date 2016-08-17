use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

can_ok('AliTV', qw(maximum_seq_length_in_json));

my $obj = new_ok('AliTV');

my @forbidden_values = (-1, "A", {}, [], 0.5);
foreach my $forbidden_value (@forbidden_values)
{
	throws_ok { $obj->maximum_seq_length_in_json($forbidden_value); } qr/Parameter needs to be an unsigned integer value/, "Exception if parameter is no unsigned integer value (used '$forbidden_value' for test)";
}

lives_ok { $obj->maximum_seq_length_in_json(12345); } 'No exception if parameter is an unsigned integer value';

# recreate our object
$obj = new_ok('AliTV');

my $expected_default = 1000000;
is($obj->maximum_seq_length_in_json(), $expected_default, 'Default value will be returned');

my $new_value = 1234567;
is($obj->maximum_seq_length_in_json($new_value), $new_value, 'New value will be returned while setting the new value');
is($obj->maximum_seq_length_in_json(), $new_value, 'New value will be returned after setting a new value');

done_testing;