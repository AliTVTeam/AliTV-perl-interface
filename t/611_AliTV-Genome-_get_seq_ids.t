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

# set_uniq_seq_names was already tested in test file: 610
$obj->set_uniq_seq_names("TestA" => "Test", "TestB" => "Test2", "TestC" => "Test3");

# define the expected sets for orig and uniq dataset
my $expected_orig = [ sort ("Test", "Test2", "Test3") ];
my $expected_uniq = [ sort ("TestA", "TestB", "TestC") ];

# run the test for the uniq seq ids
my $got_get_uniq_seq_ids = [ sort ($obj->_get_uniq_seq_ids()) ];
is_deeply($got_get_uniq_seq_ids, $expected_uniq, 'Method _get_uniq_seq_ids() returns expected result');

done_testing;
