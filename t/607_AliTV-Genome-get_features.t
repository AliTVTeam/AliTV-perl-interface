use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Genome') };

#can_ok('AliTV::Genome', qw(get_chromosomes));

my %params = (
   name => 'Test genome',
   sequence_files => ['data/test.gb'],
   feature_files => { genes => ['data/test.tsv']},
);

my $obj = new_ok('AliTV::Genome' => [%params]);

my $expected = {
   genes  => [ 
   	  { name => "irA", end => 32029, start => 6687, karyo => "NC_025642" },
   	  { name => "irB", end => 50601, start => 75943, karyo => "NC_025642" }
	  ]
};

is_deeply($obj->get_features(), $expected, 'Feature export as expected');

done_testing;
