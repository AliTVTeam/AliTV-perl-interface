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

$obj->set_uniq_seq_names("TestA" => "Test", "TestB" => "Test2", "TestC" => "Test3");

is_deeply($obj->get_chromosomes(), $expected, 'Chromosome export as expected');

done_testing;
