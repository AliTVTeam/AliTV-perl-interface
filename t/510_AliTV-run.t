use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

can_ok('AliTV', qw(run));

my $obj = new_ok('AliTV');

throws_ok { $obj->run(); } qr/No file attribute exists/, 'Exception without file attribute';


done_testing;
