use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

# this test is not required as it always has a file method
can_ok('AliTV', qw(project));

my $obj = new_ok('AliTV');

ok(! defined $obj->project(), 'Default value for project is undef');

done_testing;
