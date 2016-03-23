use strict;
use warnings;

use Test::More;
use Test::Exception;

use File::Which;

BEGIN { use_ok('AliTV::Alignment::lastz') }

can_ok( 'AliTV::Alignment::lastz', qw(_check) );

my $obj = new_ok('AliTV::Alignment::lastz');

my $old_path = $ENV{PATH};

# empty path should result in an exception
$ENV{PATH} = "";

throws_ok { $obj->_check(); } qr/Unable to find lastz/, 'Exception if lastz could not be found';

$ENV{PATH} = $old_path;

SKIP: {

  skip "lastz could not be found", 1 unless (which("lastz"));

  lives_ok { $obj->_check(); } 'Test that AliTV::Alignment::lastz found lastz';

}

done_testing;
