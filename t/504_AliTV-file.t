use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

# this test is not required as it always has a file method
can_ok('AliTV', qw(file));

my $obj = new_ok('AliTV');

# test with a non existing yml file should cause an exception
my $non_existing = 'data/chloroset/input_non_existing.yml';
throws_ok { $obj = AliTV->new("-file" => $non_existing); } qr/Unable to import the YAML file/, 'Exception is caused by non existing yml file';

# test with a single genome yml
my $file2import = 'data/single_genome.yml';
$obj->file($file2import);

is($obj->file(), $file2import, 'file returns the correct filename');

# test if the config hash contains a key genomes
ok(exists $obj->{_yml_import} && $obj->{_yml_import}{genomes}, 'Import of YAML seems to work');

# is there the default program (lastz) and a couple of default
# alignment parameters inside the yml import?
ok(exists $obj->{_yml_import}{alignment}, '(Default) alignment key was imported from default YAML');
ok(exists $obj->{_yml_import}{alignment}{program}, '(Default) alignment::program key was imported from default YAML');
is($obj->{_yml_import}{alignment}{program}, 'lastz', '(Default) alignment::program is lastz as expected');
ok(exists $obj->{_yml_import}{alignment}{parameter}, '(Default) alignment::parameter key was imported from default YAML');
is(@{$obj->{_yml_import}{alignment}{parameter}}+0, 5, '(Default) alignment::parameters number is as expected');

# test with a new config
my $chloroset = 'data/chloroset/input.yml';
$obj = new_ok('AliTV', ["-file" => $chloroset]);

ok(exists $obj->{_yml_import} && $obj->{_yml_import}{genomes}, 'Import of chloroset YAML seems to work');
is(@{$obj->{_yml_import}{genomes}}, 7, 'Number of imported genomes is correct');

done_testing;
