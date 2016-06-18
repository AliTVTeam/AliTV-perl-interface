use strict;
use warnings;

use Test::More;
use Scalar::Util qw(refaddr);
use Test::Exception;

BEGIN { use_ok('AliTV::Base') };
local *AliTV::Base::_initialize = sub {};

can_ok('AliTV::Base', qw(clone));

# check if cloned objects are not just the same reference
my $obj_a = new_ok('AliTV::Base');
my $obj_b = new_ok('AliTV::Base');

# two independent objects should not be identical
# using Scalar::Util reffaddr()
isnt(refaddr($obj_a), refaddr($obj_b), 'Two independent objects are not equal');

my $obj_c = $obj_a;
# the flat copy of $obj_a should result in identical references
# first check if $obj_c is a object
isa_ok($obj_c, 'AliTV::Base', 'Flat copies result in the correct object');
is(refaddr($obj_a), refaddr($obj_c), 'Flat copies belong to the same object');

# deep copying should result in different objects
$obj_c = $obj_a->clone();
isa_ok($obj_c, 'AliTV::Base', 'Deep copies result in the correct object');
isnt(refaddr($obj_a), refaddr($obj_c), 'Deep copies do not belong to the same object');

# deep copying as class method should fail
throws_ok { $obj_c = AliTV::Base->clone(); } qr/Cannot clone class/, 'Classes cannot be clones';

done_testing;