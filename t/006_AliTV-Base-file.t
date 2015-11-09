use strict;
use warnings;

use Test::More;
BEGIN { use_ok('AliTV::Base') };

can_ok('AliTV::Base', qw(file));

my $obj = AliTV::Base->new();

# check if the default value is undef
ok(! defined $obj->file(), 'Default value is undef');

# check if the getter works correctly, therefore set the value without setter
my $inputfile = "Testfile"; 
$obj->{file} = $inputfile;
ok($obj->file() eq $inputfile, 'Getter file works without setter');

done_testing;