use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Alignment::lastz') }

can_ok( 'AliTV::Alignment::lastz', qw(run) );

my $obj = new_ok('AliTV::Alignment::lastz');

lives_ok { $obj->run(); } 'Test that AliTV::Alignment::run was overwritten';

done_testing;
