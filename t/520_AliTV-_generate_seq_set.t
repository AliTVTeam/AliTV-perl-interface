use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

# this test is not required as it always has a file method
can_ok('AliTV', qw(_generate_seq_set));

# Two genomes with uniq sequence names
my $two_genomes_uniq_names = 'data/two_genomes_uniq_names.yml';
my $obj = new_ok('AliTV', ["-file" => $two_genomes_uniq_names]);

$obj->_import_genomes();
$obj->_make_and_set_uniq_seq_names();

$obj->_generate_seq_set();

my @expected = (
   ["Test", "ACGTTGCGTGC"], 
   ["Test2", "ACGTTGCGTG"], 
   ["Test3", "ACGTTGCGT"]
);
@expected = sort sort_seqs (@expected);
my @got = map {[$_->id(), $_->seq()]} $obj->_generate_seq_set();

is_deeply(\@got, \@expected, 'Sequence set with unique sequence names as expected');

# Two genomes with non-uniq sequence names
my $two_genomes_nonuniq_names = 'data/two_genomes_nonuniq_names.yml';
$obj = new_ok('AliTV', ["-file" => $two_genomes_nonuniq_names]);
$obj->_import_genomes();
$obj->_make_and_set_uniq_seq_names();

$obj->_generate_seq_set();

@expected = (
   ["seq0", "ACGTTGCGTGC"], 
   ["seq1", "ACGTTGCGTG"], 
   ["seq2", "ACGTTGCGT"],
   ["seq3", "ACGTTGCGTGC"], 
   ["seq4", "ACGTTGCGTG"], 
   ["seq5", "ACGTTGCGT"]
);
@expected = sort sort_seqs (@expected);
@got = map {[$_->id(), $_->seq()]} $obj->_generate_seq_set();

is_deeply(\@got, \@expected, 'Sequence set with non-unique sequence names as expected');

done_testing;

sub sort_seqs
{
   $a->[0] cmp $b->[0] 
      || 
      $a->[1] cmp $b->[1]
}
