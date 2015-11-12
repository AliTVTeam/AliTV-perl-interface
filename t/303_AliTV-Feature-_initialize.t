use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Feature') };

# this test is not required as it always has a _initialize method
can_ok('AliTV::Feature', qw(_initialize));

my $obj = new_ok('AliTV::Feature');

is(ref($obj->{features}), "HASH", 'The objects content should be stored inside a hash structure');

# the number of keys should be zero
cmp_ok((keys %{$obj->{features}})+0, '==', 0, 'The expected number of hash elements is zero');

# calling _initialize should empty the hash
$obj->{features}{something} = "Something else";

# the number of keys should be one
cmp_ok((keys %{$obj->{features}})+0, '==', 1, 'The expected number of hash elements one now');

$obj->_initialize();

# the number of keys should be one
cmp_ok((keys %{$obj->{features}})+0, '==', 0, 'The expected number of hash elements is zero again');

done_testing;
