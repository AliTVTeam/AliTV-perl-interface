use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Alignment') }

can_ok( 'AliTV::Alignment', qw(export_to_genome) );

my @output = ();

my $expected = {};
foreach (qw(f797baf2515ae41947b728131931980b c75f25c0a416592660f0d52361e40d8d 382e73453416c0192b4154131ae37572 b7428e7cc0f5fb43bcb9a6509f86def5 67be34ecadfea69f620043280783a022 8e2ba4573f148642c692d7959efe74d6 a766ac15355c0e6535d7b7702c63d087 de21569873f19d582357da39638c0f8e d8b9274a88deb0e831d5bacfc836ce05 8819c2cd8565855c31215fc4156ae405 c1ed6b600a7edbb4ea9d0cdbfada436b d8ade0e535073abdbd6693bb1df0bad8 4356f0d1cece8040c5910a2416325159 812d44b1ecb697a1d5b1302b0298099b a4e2ec0fadde220e36ae3a14c11f5de4 e46c3a33df0179b0b0cdde6c61d6513c 4e2f36dfa3fd9da4368c3176ab53b2f7 5890f9fd52c816f20701652df493109b 352afd590de0fad19ece44a04736af2f 503caa9344b4dc816c51c8844a4a0701 fb56b3290ea7f7eea7ef643199f95f3b))
{
	$expected->{$_}++;
}

my @input_files = (
   'data/vectors/001.maf',
   'data/vectors/002.maf',
   'data/vectors/003.maf',
   'data/vectors/004.maf'
);

# without callback
my $obj = new_ok('AliTV::Alignment');

$obj->import_alignments(@input_files);

throws_ok { $obj->export_to_genome() } qr/Callback needs to be specified/, 'Exception without callback function';

# with callback
my %output = ();
$obj = new_ok('AliTV::Alignment', [ -callback => sub { my ($dat) = @_;  my $md5 = $dat->{md5}; $output{$md5}++; } ]);

$obj->import_alignments(@input_files);

$obj->export_to_genome();

is_deeply(\%output, $expected, 'Callback works');

done_testing;
