use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Genome') };

can_ok('AliTV::Genome', qw(get_sequences));

my %params = (
   name => 'Test genome',
   sequence_files => ['data/fasta-input.fasta', 'data/fasta-input2.fasta']
);

my $obj = new_ok('AliTV::Genome' => [%params]);

# following statement is tested by 610_AliTV-Genome-set_uniq_seq_names.t
$obj->set_uniq_seq_names("TestA" => "Test", "TestB" => "Test2", "TestC" => "Test3");

my $expected = [
   [ "TestA", "ACGTTGCGTGC" ],
   [ "TestB", "ACGTTGCGTG" ],
   [ "TestC", "ACGTTGCGT" ]
];

my @got = map { [$_->id(), $_->seq()] } ($obj->get_sequences());

is_deeply(\@got, $expected, 'Sequence export as expected');

done_testing;
