use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Alignment') }

can_ok( 'AliTV::Alignment', qw(_check) );

my $obj = new_ok('AliTV::Alignment');

throws_ok { $obj->_check(); }
qr/Method AliTV::Alignment::_check\(\) need to be overwritten.*/,
  'Test that AliTV::Alignment::_check() need to be overwritten';

done_testing;
