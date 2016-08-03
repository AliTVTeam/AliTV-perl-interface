use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Genome') };

can_ok('AliTV::Genome', qw(set_uniq_seq_names));

my %params = (
   name => 'Test genome',
   sequence_files => ['data/fasta-input.fasta', 'data/fasta-input2.fasta']
);

my $obj = new_ok('AliTV::Genome' => [%params]);

my $expected = {
   TestA  => { length => 11, seq => "ACGTTGCGTGC", genome_id => "Test genome", name => "Test" },
   TestB => { length => 10, seq => "ACGTTGCGTG" , genome_id => "Test genome", name => "Test2" },
   TestC => { length =>  9, seq => "ACGTTGCGT"  , genome_id => "Test genome", name => "Test3" },
};

my %uniq_name_assignment = ("TestA" => "Test", "TestB" => "Test2", "TestC" => "Test3");
$obj->set_uniq_seq_names(%uniq_name_assignment);
my $got = $obj->get_chromosomes();

is_deeply($got, $expected, 'Chromosome export as expected');

# if number of assigned items is not correct, the call should die
my %uniq_name_assignment_wrong = ("TestA" => "Test", "TestB" => "Test2");
throws_ok { $obj->set_uniq_seq_names(%uniq_name_assignment_wrong); } qr/Unique identifier does not cover all original identifier!/, 'Exception caused by the incorrect number of unique sequence ID';
my %uniq_name_assignment_wrong2 = ("TestA" => "Test", "TestB" => "Test2", "TestD" => "Test4");
throws_ok { $obj->set_uniq_seq_names(%uniq_name_assignment_wrong2); } qr/Unique identifier does not cover all original identifier!/, 'Exception caused by the incorrect number of unique sequence ID2';

my %uniq_name_assignment_wrong3 = ("TestA" => "Test", "TestB" => "Test2", "TestD" => "Test2");
throws_ok { $obj->set_uniq_seq_names(%uniq_name_assignment_wrong3); } qr/Unique identifier does not cover all original identifier!/, 'Exception caused by the incorrect number of unique sequence ID3';

done_testing;
