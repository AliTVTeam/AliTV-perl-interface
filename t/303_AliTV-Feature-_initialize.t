use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Feature') };

# this test is not required as it always has a _initialize method
can_ok('AliTV::Feature', qw(_initialize));

my $obj = new_ok('AliTV::Feature');

foreach my $attribute (qw(_features _files _current_feature_type _current_feature_index))
{
	ok(exists $obj->{$attribute}, 
	"The object has an attribute named '$attribute'");
}

done_testing;
