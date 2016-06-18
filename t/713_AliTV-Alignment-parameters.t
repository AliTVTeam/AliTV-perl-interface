use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Alignment') };

can_ok('AliTV::Alignment', qw(parameters));

my $obj = new_ok('AliTV::Alignment');

ok(! defined $obj->parameters(), 'Default value is not defined');

my $expected = "Value";

is( $obj->parameters($expected), $expected, 'Expected value is retured when set');
is( $obj->parameters(), $expected, 'Expected value is stored when set');

done_testing;
