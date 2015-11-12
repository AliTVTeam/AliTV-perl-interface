use strict;
use warnings;

use Test::More;
use Test::Exception;
use Bio::SeqIO;

BEGIN { use_ok('AliTV::Seq') };

# this test is not required as it always has a file method
can_ok('AliTV::Seq', qw(from_bioseq));

my $obj = new_ok('AliTV::Seq');

# generate a bioseq object
my $filename = 'data/fasta-input.fasta';
my $fileio  = Bio::SeqIO->new(-file => $filename);
my $bioseq_obj = $fileio->next_seq();

# and use it to initalize the object content
$obj->from_bioseq($bioseq_obj);

# test if the data are correct
is($obj->id(), "Test", 'Returned ID is correct');
is($obj->seq(), "ACGTTGCGTGC", 'Returned sequence is correct');
cmp_ok($obj->seqlength(), '==', 11, 'Returned sequence length is correct');

# check if the usage of a non Bio::Seq object as input results in an
# exception

throws_ok { $obj->from_bioseq(\("Non Bio::Seq object")) } qr/The parameter does not seem to be a Bio::Seq object/, 'Exception when using a non Bio::Seq as input';

done_testing;
