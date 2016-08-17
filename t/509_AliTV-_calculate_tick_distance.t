use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

can_ok('AliTV', qw(_calculate_tick_distance ticks_every_num_of_bases));

my $obj = new_ok('AliTV');

my @forbidden_values = (-1, "A", {}, [], 0.5);
foreach my $forbidden_value (@forbidden_values)
{
	throws_ok { $obj->ticks_every_num_of_bases($forbidden_value); } qr/Parameter needs to be an unsigned integer value/, "Exception if parameter is no unsigned integer value (used '$forbidden_value' for test)";
}

done_testing;