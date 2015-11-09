use strict;
use warnings;

use Test::More;
use Scalar::Util qw(refaddr);

BEGIN { use_ok('AliTV::Base') };

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

done_testing;