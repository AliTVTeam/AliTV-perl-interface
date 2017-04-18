use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Genome') };

#can_ok('AliTV::Genome', qw(get_chromosomes));

my %params = (
    name => 'Test genome',
    sequence_files => ['data/test_feature.gb'],
    feature_files => { genes => ['data/test_feature.tsv']},
    );

my $obj = new_ok('AliTV::Genome' => [%params]);

my $expected = {
    genes  => [
	{ name => "tet", end => 1276, start => 86, karyo => "SYNPBR322" },
	{ name => "bla", end => 3293, start => 4153, karyo => "SYNPBR322" }
	]
};

is_deeply($obj->get_features(), $expected, 'Feature export as expected');

my $obj_uniq_names = new_ok('AliTV::Genome' => [%params]);

$obj->set_uniq_seq_names( "seq1" => "SYNPBR322");

my $expected_after_uniq_names = {
    genes  => [
	{ name => "tet", end => 1276, start => 86, karyo => "seq1" },
	{ name => "bla", end => 3293, start => 4153, karyo => "seq1" }
	]
};

is_deeply($obj->get_features(), $expected_after_uniq_names, 'Feature export after creating unique names as expected');

my %params_with_gff = (
    name => 'Test genome',
    sequence_files => ['data/test_feature.gb'],
    feature_files => { gene => ['data/test_feature.gff']},
    );

my $obj_with_gff = new_ok('AliTV::Genome' => [%params_with_gff]);

my $expected_with_gff = {
    gene  => [
	{ name => "tet", end => 1276, start => 86, karyo => "SYNPBR322" },
	{ name => "bla", end => 3293, start => 4153, karyo => "SYNPBR322" }
	]
};

is_deeply($obj_with_gff->get_features(), $expected_with_gff, 'Feature export as expected after GFF import');

done_testing;
