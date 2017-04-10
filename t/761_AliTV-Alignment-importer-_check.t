use strict;
use warnings;

use Test::More;
use Test::Exception;

use File::Which;

BEGIN { use_ok('AliTV::Alignment::importer') }

can_ok( 'AliTV::Alignment::importer', qw(_check) );

my $obj = new_ok('AliTV::Alignment::importer');

lives_ok { $obj->_check(); } 'Check can be called without exception';

done_testing;
