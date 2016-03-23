use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Alignment::lastz') }

can_ok( 'AliTV::Alignment::lastz', qw(_check) );

my $obj = new_ok('AliTV::Alignment::lastz');

lives_ok { $obj->_check(); } 'Test that AliTV::Alignment::_check() was overwritten';

done_testing;
