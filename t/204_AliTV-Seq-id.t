use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Seq') };

can_ok('AliTV::Seq', qw(id));

my $obj = new_ok('AliTV::Seq');

# is the default id undef?
ok(! defined $obj->id(), 'Empty object id is undef');

done_testing;
