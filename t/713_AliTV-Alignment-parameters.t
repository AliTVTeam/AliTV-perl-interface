use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Alignment') };

can_ok('AliTV::Alignment', qw(parameters));

my $obj = new_ok('AliTV::Alignment');

is_deeply($obj->parameters(), [], 'Default value is an empty array');

my @values = ("ValueA", "ValueB", 15);

my $expected = [$values[0]];

is_deeply( $obj->parameters(@{$expected}), $expected, 'Expected value is retured when set');
is_deeply( $obj->parameters(), $expected, 'Expected value is stored when set');

is_deeply( $obj->parameters(@values), \@values, 'Expected values are retured when set as array');
is_deeply( $obj->parameters(), \@values, 'Expected values are stored when set as array');

is_deeply( $obj->parameters(\@values), \@values, 'Expected values are retured when set as array reference');
is_deeply( $obj->parameters(), \@values, 'Expected values are stored when set as array reference');

done_testing;
