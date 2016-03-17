use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Genome') };

# this test is not required as it always has a file method
can_ok('AliTV::Genome', qw(file));

my $obj = new_ok('AliTV::Genome');

throws_ok { $obj->file(); } qr/File should never called for AliTV::Genome/, 'File is not necessary for Genome';

done_testing;
