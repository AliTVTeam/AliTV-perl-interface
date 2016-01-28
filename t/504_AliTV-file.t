use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

# this test is not required as it always has a file method
can_ok('AliTV', qw(file));

my $obj = new_ok('AliTV');

my $file2import = 'data/single_genome.yml';
$obj->file($file2import);

is($obj->file(), $file2import, 'file returns the correct filename');

# test if the config hash contains a key genomes
ok(exists $obj->{_yml_import} && $obj->{_yml_import}{genomes}, 'Import of YAML seems to work');

done_testing;
