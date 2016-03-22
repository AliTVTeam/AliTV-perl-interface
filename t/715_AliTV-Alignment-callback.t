use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Alignment') };

can_ok('AliTV::Alignment', qw(callback));

my $obj = new_ok('AliTV::Alignment');

ok(! defined $obj->callback(), 'Default value is not defined');

my $expected = sub { };

is( $obj->callback($expected), $expected, 'Expected value is retured when set');
is( $obj->callback(), $expected, 'Expected value is stored when set');

$expected = "Value";
throws_ok { $obj->callback($expected); }
	  qr/Callback need to be a code reference!/,
          'Exception if no codereference is provided for callback';

done_testing;
