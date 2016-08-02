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

# followed by the test for the orig seq ids
my $got_get_orig_seq_ids = [ sort ($obj->_get_orig_seq_ids()) ];
is_deeply($got_get_orig_seq_ids, $expected_orig, 'Method _get_orig_seq_ids() returns expected result');

# last run the different tests for _get_seq_ids
# for a new object
my $obj_new = new_ok('AliTV::Genome' => [%params]);

my $expected_die_msg = qr/Use 'uniq' or 'orig' as parameter for the method _get_seq_ids and ensure, that unique names have been generated./;

throws_ok { $obj_new->_get_seq_ids(); } $expected_die_msg, 'Exception if no parameter was given';
throws_ok { $obj_new->_get_seq_ids('not_uniq_or_orig'); } $expected_die_msg, 'Exception if parameter is not uniq or orig';
throws_ok { $obj_new->_get_seq_ids('uniq'); } $expected_die_msg, 'Exception if uniq is used without unique sequence names';
my $got_get_seq_ids_orig = [sort $obj_new->_get_seq_ids('orig')];
is_deeply($got_get_seq_ids_orig, $expected_orig, 'Method _get_seq_ids("orig") returns expected result without unique sequence names');

# set_uniq_seq_names to initialize unique names
$obj_new->set_uniq_seq_names("TestA" => "Test", "TestB" => "Test2", "TestC" => "Test3");

throws_ok { $obj_new->_get_seq_ids(); } $expected_die_msg, 'Exception if no parameter was given after initialization';
throws_ok { $obj_new->_get_seq_ids('not_uniq_or_orig'); } $expected_die_msg, 'Exception if parameter is not uniq or orig after initialization';

my $got_get_seq_ids_uniq_after_initialization = [sort $obj_new->_get_seq_ids('uniq')];
is_deeply($got_get_seq_ids_uniq_after_initialization, $expected_uniq, 'Method _get_seq_ids("uniq") returns expected result after creation of unique sequence names');

my $got_get_seq_ids_orig_after_initialization = [sort $obj_new->_get_seq_ids('orig')];
is_deeply($got_get_seq_ids_orig_after_initialization, $expected_orig, 'Method _get_seq_ids("orig") returns expected result after creation of unique sequence names');

done_testing;
