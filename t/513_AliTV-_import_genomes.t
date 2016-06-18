use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

can_ok('AliTV', qw(_import_genomes));

my $obj = new_ok('AliTV');

throws_ok { $obj->_import_genomes(); } qr/No file attribute exists/, 'Exception without file attribute';

# Testing with chloroset
my $chloroset_fail = 'data/chloroset/input_same_id_twice.yml';
$obj = new_ok('AliTV', ["-file" => $chloroset_fail]);

throws_ok { $obj->_import_genomes(); } qr/Genome-ID .* is not uniq/, 'Exception with non-uniq genome ID';

my $chloroset = 'data/chloroset/input.yml';
$obj = new_ok('AliTV', ["-file" => $chloroset]);

$obj->_import_genomes();

ok(exists $obj->{_genomes}, 'Attribute _genomes exists');
is(keys %{$obj->{_genomes}}, 7, 'Number of genomes as expected');

done_testing;
