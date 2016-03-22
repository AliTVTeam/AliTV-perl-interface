use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Alignment') };

# this test is not required as it always has a file method
can_ok('AliTV::Alignment', qw(file));

my $obj = new_ok('AliTV::Alignment');

throws_ok { $obj->file(); } qr/File should never called for AliTV::Alignment/, 'File is not necessary for Alignment';

done_testing;
