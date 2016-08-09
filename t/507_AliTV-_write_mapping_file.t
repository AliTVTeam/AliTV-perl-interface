use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

# this test is not required as it always has a file method
can_ok('AliTV', qw(_write_mapping_file));

my $obj = new_ok('AliTV');

throws_ok { $obj->_write_mapping_file(); } qr/Need to call _write_mapping_file\(\) with an array reference as parameter/, 'Exception if called without a parameter';

throws_ok { $obj->_write_mapping_file(1); } qr/Need to call _write_mapping_file\(\) with an array reference as parameter but found other type/, 'Exception if called without a array reference as parameter';

done_testing;