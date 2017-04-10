use strict;
use warnings;

use Test::More;
use Test::Exception;
use Bio::SeqIO;

BEGIN { use_ok('AliTV::Alignment') }

can_ok( 'AliTV::Alignment', qw(export_to_genome) );

my @output = ();

my $expected = {
    '2451b5e81180ecf654e5be0706ac1c24' => 1,
    '2b1a5a044bc636fa64ef0203aa54e365' => 1,
    '2ccc558a7385e62eda6e0ca09d907f2a' => 1,
    '36c615a96f030f9fb3bbe8f7d2359fef' => 1,
    '382e73453416c0192b4154131ae37572' => 1,
    '3e3ba56b295b104c1d6bf5d07137712c' => 1,
    '4859d36239431e6feae49c9653d96bed' => 1,
    '4f0d52ca2ec183afa3b550c9cc5e415e' => 1,
    '6378b4362b147ad7a6e89431784bf498' => 1,
    '67be34ecadfea69f620043280783a022' => 1,
    '7273b3729521163a3108a23ac3bdf5e1' => 1,
    '8819c2cd8565855c31215fc4156ae405' => 1,
    '8e2ba4573f148642c692d7959efe74d6' => 1,
    'b7428e7cc0f5fb43bcb9a6509f86def5' => 1,
    'c75f25c0a416592660f0d52361e40d8d' => 1,
    'ca0660bebbb72988e48dc311a29e5893' => 1,
    'db29a9d74a2b861b3922325e2a039cb7' => 1,
    'e1995f7a38c1fa5c2ba388ac198f7e4d' => 1,
    'e3b6fc5ba87814e53424a1fdc398a5a5' => 1,
    'ee136cf69b7e4c691580f79374ca4c45' => 1,
    'f797baf2515ae41947b728131931980b' => 1
};

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

# without callback
my $obj = new_ok('AliTV::Alignment');

$obj->sequence_set(\@seq_set);

$obj->import_alignments(@input_files);

throws_ok { $obj->export_to_genome() } qr/Callback needs to be specified/, 'Exception without callback function';

# with callback
my %output = ();
$obj = new_ok('AliTV::Alignment', [ -callback => sub { my ($dat) = @_;  my $md5 = $dat->{md5}; $output{$md5}++; } ]);

$obj->sequence_set(\@seq_set);

$obj->import_alignments(@input_files);

$obj->export_to_genome();

TODO: {
    local $TODO = "Need to recalculate the expected values";
    is_deeply(\%output, $expected, 'Callback works');
};

done_testing;
