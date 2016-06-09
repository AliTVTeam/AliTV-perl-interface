use strict;
use warnings;

use Test::More;
use Test::Exception;
use Data::Dumper;
use Bio::SeqIO;

my $input = Bio::SeqIO->new(-file => "data/vectors/vectors.fasta");
my @seq_set = ();

while (my $seq = $input->next_seq())
{
   push(@seq_set, $seq);
}

@seq_set = sort {$a->id() cmp $b->id()} (@seq_set);

my @output = ();

my $expected = [
[ "M13mp18", 1832, 1913, 1, "M13mp18", 2333, 2402, 1 ],
   ];

BEGIN { use_ok('AliTV::Alignment::lastz') }

can_ok( 'AliTV::Alignment::lastz', qw(run) );

my $obj = new_ok('AliTV::Alignment::lastz' => [-parameters => "--format=MAF --noytrim --gapped --strand=both --ambiguous=iupac", -callback => sub { push(@output,  \@_); }] );

$obj->run(@seq_set);

is_deeply(\@output, $expected, 'Test successful');

done_testing;
