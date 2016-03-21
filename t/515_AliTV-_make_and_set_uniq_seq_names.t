use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV') };

# this test was introduced, due to the fact, that I tried to reread
# the DATA section of the AliTV.pm. To avoid this problem again, I
# added a test which test if multiple calls of get_default_settings()
# will produce the same result.

# this test is not required as it always has a file method
can_ok('AliTV', qw(_make_and_set_uniq_seq_names));

# Two genomes with uniq sequence names
my $two_genomes_uniq_names = 'data/two_genomes_uniq_names.yml';
my $obj = new_ok('AliTV', ["-file" => $two_genomes_uniq_names]);
$obj->_import_genomes();

$obj->_make_and_set_uniq_seq_names();

my $expected = [sort ("Test", "Test2", "Test3")];
my $got = get_sequence_ids($obj);

is_deeply($got, $expected, 'Unique sequences names are not changed');

# Two genomes with non-uniq sequence names
my $two_genomes_nonuniq_names = 'data/two_genomes_nonuniq_names.yml';
$obj = new_ok('AliTV', ["-file" => $two_genomes_nonuniq_names]);
$obj->_import_genomes();

$obj->_make_and_set_uniq_seq_names();

$expected = [sort ("seq0", "seq1", "seq2", "seq3", "seq4", "seq5")];
$got = get_sequence_ids($obj);

is_deeply($got, $expected, 'Non-unique sequences names are changed');

done_testing;

sub get_sequence_ids
{
   my $self = shift;
   my @all_seq_ids = ();

   foreach my $genome_id (sort keys %{$self->{_genomes}})
   {
      push(@all_seq_ids, (keys %{$self->{_genomes}{$genome_id}->get_chromosomes()}));
   }

   return [ sort (@all_seq_ids) ];

}
