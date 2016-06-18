use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Seq') };

# this test is not required as it always has a file method
can_ok('AliTV::Seq', qw(file));

my $obj = new_ok('AliTV::Seq');

$obj->file('data/fasta-input.fasta');

is($obj->id(), "Test", 'Returned ID is correct');
is($obj->seq(), "ACGTTGCGTGC", 'Returned sequence is correct');
cmp_ok($obj->seqlength(), '==', 11, 'Returned sequence length is correct');

done_testing;
