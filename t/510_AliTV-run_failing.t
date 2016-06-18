use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

can_ok('AliTV', qw(run));

my $obj = new_ok('AliTV');

throws_ok { $obj->run(); } qr/No file attribute exists/, 'Exception without file attribute';

# Testing with chloroset
my $chloroset_fail = 'data/chloroset/input_same_id_twice.yml';
$obj = new_ok('AliTV', ["-file" => $chloroset_fail]);

throws_ok { $obj->run(); } qr/Genome-ID .* is not uniq/, 'Exception with non-uniq genome ID';

done_testing;
