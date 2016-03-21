use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Genome') };

can_ok('AliTV::Genome', qw(get_seq_names));

my %params = (
   name => 'Test genome',
   sequence_files => ['data/fasta-input.fasta', 'data/fasta-input2.fasta']
);

my $obj = new_ok('AliTV::Genome' => [%params]);

my $expected = [ sort ("Test", "Test2", "Test3") ];
my $got = [ sort ($obj->get_seq_names()) ];

is_deeply($got, $expected, 'Names of sequences can be retrieved');

done_testing;
