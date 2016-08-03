use strict;
use warnings;

use Test::More;
use Test::Exception;
use YAML;

BEGIN { use_ok('AliTV') };

# this test was introduced, due to the fact, that I tried to reread
# the DATA section of the AliTV.pm. To avoid this problem again, I
# added a test which test if multiple calls of get_default_settings()
# will produce the same result.

can_ok('AliTV', qw(get_default_settings));

my $obj = new_ok('AliTV');

my $expected_yml = join("", <DATA>);
my $expected = YAML::Load($expected_yml);

is_deeply($obj->{_yml_import}, $expected, 'First parsing of default set works');
is_deeply($obj->get_default_settings(), $expected, 'Multiple calls of get_default_settings() as object method return the same settings 1st attempt');
is_deeply($obj->get_default_settings(), $expected, 'Multiple calls of get_default_settings() as object method return the same settings 2nd attempt');

is_deeply(AliTV::get_default_settings(), $expected, 'Multiple calls of get_default_settings() as class method return the same settings 1st attempt');
is_deeply(AliTV::get_default_settings(), $expected, 'Multiple calls of get_default_settings() as class method return the same settings 2nd attempt');

done_testing;

__DATA__
---
# this is the default yml file
output:
    data: data.json
    conf: conf.json
    filter: filter.json
alignment:
    program: lastz
    parameter:
       - "--format=maf"
       - "--noytrim"
       - "--ambiguous=iupac"
       - "--gapped"
       - "--strand=both"

