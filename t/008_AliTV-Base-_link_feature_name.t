use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Base') };
local *AliTV::Base::_initialize = sub {};

can_ok('AliTV::Base', qw(_link_feature_name));

my $obj = new_ok('AliTV::Base');

my $expected = "link";

is($obj->_link_feature_name(), $expected, 'Object method call works');
is(AliTV::Base->_link_feature_name(), $expected, 'Class method call works');

done_testing;