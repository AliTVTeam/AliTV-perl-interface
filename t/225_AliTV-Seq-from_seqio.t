use strict;
use warnings;

use Test::More;
use Test::Exception;
use Bio::SeqIO;

BEGIN { use_ok('AliTV::Seq') };

# this test is not required as it always has a file method
can_ok('AliTV::Seq', qw(from_seqio));

my $obj = new_ok('AliTV::Seq');

# generate a seqio object
my $filename = 'data/fasta-input.fasta';
my $fileio  = Bio::SeqIO->new(-file => $filename);
my $seqio_obj = $fileio->next_seq();

# and use it to initalize the object content
$obj->from_seqio($seqio_obj);

# test if the data are correct
is($obj->id(), "Test", 'Returned ID is correct');
is($obj->seq(), "ACGTTGCGTGC", 'Returned sequence is correct');
cmp_ok($obj->seqlength(), '==', 11, 'Returned sequence length is correct');

done_testing;
