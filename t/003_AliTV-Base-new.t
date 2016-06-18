use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Base') };
local *AliTV::Base::_initialize = sub {};

can_ok('AliTV::Base', qw(new));

my $obj = new_ok('AliTV::Base');

# check if the setter/getter call fails in case of odd number of arguments
throws_ok { $obj = AliTV::Base->new("-odd_number_of_arguments"); } qr/The number of arguments was odd/, 'Exception when using an odd number of arguments';

# check if the setter/getter call fails in case of names starting without dash
# throws_ok { $obj = AliTV::Base->new(attribute_without_dash => "Value"); }
#	  qr/The attribute .* does not start with a leading dash!/, 'Exception when attribute does not start with dash';

# check if the setter/getter call fails in case of non missing setter
throws_ok { $obj = AliTV::Base->new(-unknown_attribute => "Value"); }
	  qr/The attribute .* has no setter in class/, 'Exception when attribute has no setter';

done_testing;