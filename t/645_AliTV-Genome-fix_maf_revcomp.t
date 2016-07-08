use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Genome') };

can_ok('AliTV::Genome', qw(fix_maf_revcomp));

my %params = (
   name => 'Test genome',
   sequence_files => ['data/fasta-input.fasta', 'data/fasta-input2.fasta']
);

my $obj = new_ok('AliTV::Genome' => [%params]);

my ($start, $end, $strand, $seqname) = (2, 5, 1, "Test");

my ($got_start, $got_end) = $obj->fix_maf_revcomp($start, $end, $strand, $seqname);
is($got_start, $start, 'Start correct if strand +1');
is($got_end, $end, 'End correct if strand +1');

done_testing;
