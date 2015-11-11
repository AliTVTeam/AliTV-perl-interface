use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Seq') };

can_ok('AliTV::Seq', qw(prep_json));

my $obj = new_ok('AliTV::Seq');

$obj->file('data/fasta-input.fasta');

my $expected = {
   length => 11,
   seq => "ACGTTGCGTGC",
   genome_id => "Test"
   };

is_deeply($obj->output(), $expected, 'The expected hash reference is returned');

done_testing;
