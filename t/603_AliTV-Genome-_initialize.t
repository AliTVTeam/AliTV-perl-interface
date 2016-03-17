use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Genome') };

# this test is not required as it always has a _initialize method
can_ok('AliTV::Genome', qw(_initialize));

my $obj = new_ok('AliTV::Genome');

lives_ok { $obj->_initialize() } 'Overwritten function should avoid exception';

my $testname = "Species1";
$obj->_initialize(name => $testname);

is($obj->name(), $testname, 'Name can be set');

my $testinputfile = ['data/fasta-input.fasta'];
$obj->_initialize(sequence_files => $testinputfile);

# check if the sequence id is Test
ok(exists $obj->{_seq}{Test}, "Import of correct ID successful");
# check if the sequence length is 11
is($obj->{_seq}{Test}{len}, 11, "Import of correct sequence length successful");
# check if the sequence is correct
is($obj->{_seq}{Test}{seq}, "ACGTTGCGTGC", "Import of correct sequence successful");

$testinputfile = ['data/fasta-input.fasta', 'data/fasta-input2.fasta'];
$obj->_initialize(sequence_files => $testinputfile);

my $expected_set = {
   Test  => { seq => "ACGTTGCGTGC", len => 11 },
   Test2 => { seq => "ACGTTGCGTG", len => 10 },
   Test3 => { seq => "ACGTTGCGT", len => 9 }
   };

foreach my $id (keys %{$expected_set})
{
   # check if the sequence id is correct
   ok(exists $obj->{_seq}{$id}, "Import of correct ID successful");
   # check if the sequence length is correct
   is($obj->{_seq}{$id}{len}, $expected_set->{$id}{len}, "Import of correct sequence length successful");
   # check if the sequence is correct
   is($obj->{_seq}{$id}{seq}, $expected_set->{$id}{seq}, "Import of correct sequence successful");
}

$testinputfile = ['data/fasta-input_double_id.fasta'];
throws_ok { $obj->_initialize(sequence_files => $testinputfile); }
	  qr/The sequence ID .* seems to be multiple times present in file/,
	  'Identical IDs result in exception';


done_testing;
