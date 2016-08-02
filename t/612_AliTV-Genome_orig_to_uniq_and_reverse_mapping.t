use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Genome') };

can_ok('AliTV::Genome', qw(_get_seq_ids _get_uniq_seq_ids _get_orig_seq_ids));

my %params = (
   name => 'Test genome',
   sequence_files => ['data/fasta-input.fasta', 'data/fasta-input2.fasta']
);

my $obj = new_ok('AliTV::Genome' => [%params]);

# define the expected sets for orig and uniq dataset
my @expected_orig = ("Test", "Test2", "Test3");
my @expected_uniq = ("TestA", "TestB", "TestC");

done_testing;
