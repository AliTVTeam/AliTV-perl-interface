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

# Testing with a wrong alignment program
# sets a wrong alignment program (lastzz instead of lastz)
my $vectorset_pass = 'data/vectors/input_wrong_alignmentprogram.yml';
$obj = new_ok('AliTV', ["-file" => $vectorset_pass]);

throws_ok { $obj->run(); } qr/Unable to load alignment module 'AliTV::Alignment::lastzz'/, 'Exception with wrong alignment module';

done_testing;
