use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

# this test was introduced, due to the fact, that I tried to reread
# the DATA section of the AliTV.pm. To avoid this problem again, I
# added a test which test if multiple calls of get_default_settings()
# will produce the same result.

# this test is not required as it always has a file method
can_ok('AliTV', qw(file));

my $obj = new_ok('AliTV');

my $expected = $obj->{_yml_import};

is_deeply($obj->_get_default_settings(), $expected, 'Multiple calls of _get_default_settings() return the same settings 1st attempt');
is_deeply($obj->_get_default_settings(), $expected, 'Multiple calls of _get_default_settings() return the same settings 2nd attempt');

done_testing;
