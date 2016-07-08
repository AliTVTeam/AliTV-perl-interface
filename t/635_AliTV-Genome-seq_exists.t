use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Genome') };

can_ok('AliTV::Genome', qw(seq_exists));

my %params = (
   name => 'Test genome',
   sequence_files => ['data/fasta-input.fasta', 'data/fasta-input2.fasta']
);

my $obj = new_ok('AliTV::Genome' => [%params]);

my %expected =  (
   "Test" => 1,
   "Test2" => 1,
   "Test3" => 1,
   "Test4" => undef
);

while (my ($name, $exp_result) = each %expected)
{
	is($obj->seq_exists($name), $exp_result, "Correct value for sequence name '$name' was returned");
}

done_testing;
