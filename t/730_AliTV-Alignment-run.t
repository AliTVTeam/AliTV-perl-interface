use strict;
use warnings;

use Test::More;
use Test::Exception;
local *AliTV::Alignment::_check = sub {};

BEGIN { use_ok('AliTV::Alignment') }

can_ok( 'AliTV::Alignment', qw(run) );

my $obj = new_ok('AliTV::Alignment');

throws_ok { $obj->run(); }
qr/Method AliTV::Alignment::run\(\) need to be overwritten/,
  'Test that AliTV::Alignment::_check() need to be overwritten';

done_testing;
