use strict;
use warnings;

use Test::More;
use Bio::SeqIO;
local *AliTV::Alignment::_check = sub {};

BEGIN { use_ok('AliTV::Alignment') }

# collect all messages logged via _info
my @info_messages = ();
no warnings 'redefine';
local *AliTV::Alignment::_info = sub { push(@info_messages, $_[1]); };
use warnings 'redefine';

my @input_files = (
   'data/vectors/001.maf',
   'data/vectors/002.maf',
   'data/vectors/003.maf',
   'data/vectors/004.maf'
);

my $input = Bio::SeqIO->new(-file => "data/vectors/vectors.fasta");
my @seq_set = ();

while (my $seq = $input->next_seq())
{
   push(@seq_set, $seq);
}

my $obj = new_ok('AliTV::Alignment');

$obj->sequence_set(\@seq_set);

$obj->import_alignments(@input_files);

my @maf_messages = grep { /^MAF input file/ } @info_messages;
is(scalar(@maf_messages), 1, 'The message about the BioPerl MAF workaround is logged only once for several MAF files');

# a second import with the same object must not repeat the message
$obj->import_alignments($input_files[0]);

@maf_messages = grep { /^MAF input file/ } @info_messages;
is(scalar(@maf_messages), 1, 'The message about the BioPerl MAF workaround is not repeated by a second import');

done_testing;
