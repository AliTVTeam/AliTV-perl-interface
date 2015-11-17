use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Base') };

can_ok('AliTV::Base', qw(_initialize));

throws_ok { AliTV::Base->_initialize(); } qr/You need to overwrite the method AliTV::Base::_initialize()/, 'Original AliTV::Base::_initialize() method should create an exception';

throws_ok { my $obj = AliTV::Base->new(); } qr/You need to overwrite the method AliTV::Base::_initialize()/, 'Calling new() for AliTV::Base should also create an exception';

done_testing;
