use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Genome') };

can_ok('AliTV::Genome', qw(get_chromosomes));

my %params = (
   name => 'Test genome',
   sequence_files => ['data/fasta-input.fasta', 'data/fasta-input2.fasta']
);

my $obj = new_ok('AliTV::Genome' => [%params]);

my $expected = {
   Test  => { length => 11, seq => "ACGTTGCGTGC", genome_id => "Test genome", name => "Test" },
   Test2 => { length => 10, seq => "ACGTTGCGTG" , genome_id => "Test genome", name => "Test2" },
   Test3 => { length =>  9, seq => "ACGTTGCGT"  , genome_id => "Test genome", name => "Test3" },
};

is_deeply($obj->get_chromosomes(), $expected, 'Chromosome export as expected');

done_testing;
