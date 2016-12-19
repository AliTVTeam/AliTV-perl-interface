use strict;
use warnings;

use Test::More;
use Test::Exception;

use Bio::SeqIO;

BEGIN { use_ok('AliTV::Alignment') };

can_ok('AliTV::Alignment', qw(sequence_set));

my $obj = new_ok('AliTV::Alignment');

# test sequence set
my $expected_default = [];
my $input = Bio::SeqIO->new(-file => "data/vectors/vectors.fasta");
my @seq_set = ();

while (my $seq = $input->next_seq())
{
   push(@seq_set, $seq);
}

my $expected = \@seq_set;

# run the tests
is_deeply($obj->sequence_set(), $expected_default, 'Default value is an empty array');

is_deeply( $obj->sequence_set(\@seq_set), $expected, 'Expected value is retured when set');
is_deeply( $obj->sequence_set(), $expected, 'Expected value is stored when set');

done_testing;
