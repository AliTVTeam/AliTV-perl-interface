use strict;
use warnings;

use Test::More;
use Test::Exception;
use Storable qw(dclone);

BEGIN { use_ok('AliTV::Genome') }

can_ok( 'AliTV::Genome', qw(_store_feature) );

my %params = (
    name           => 'Test genome',
    sequence_files => ['data/test.gb'],
    feature_files  => { genes => ['data/test.tsv'] },
);

my $obj = new_ok( 'AliTV::Genome' => [%params] );

# this is tested in 607_AliTV-Genome-get_features.t

my %links = (
    link001 =>
      { start => 1000, end => 2000, karyo => "NC_025642", strand => 1 },
    link002 =>
      { start => 1000, end => 2000, karyo => "NC_025642", strand => -1 },
    link003 =>
      { start => 1000, end => 2000, karyo => "NC_025642", strand => -1 },
);

# now add a single link

my $expected_case_1 = {
    genes => [
        { name => "irA", end => 32029, start => 6687,  karyo => "NC_025642" },
        { name => "irB", end => 50601, start => 75943, karyo => "NC_025642" }
    ],
    link => {
        "link001" => {
            end   => $links{link001}{end},
            start => $links{link001}{start},
            karyo => $links{link001}{karyo}
        },
    }
};

my $expected_case_2 = dclone($expected_case_1);
$expected_case_2->{link}{link002} = {
    end   => $links{link001}{start},
    start => $links{link001}{end},
    karyo => $links{link001}{karyo}
};

# First add the first link
my $name_case_1          = "link001";
my $name_returned_case_1 = $obj->_store_feature( $obj->_link_feature_name(),
    ( map { $links{$name_case_1}{$_} } (qw(karyo start end strand)) ),
    $name_case_1 );

is( $name_returned_case_1, $name_case_1,
    'Correct name was returned for case 1' );
is_deeply( $obj->get_features(), $expected_case_1,
    'Links are generated as expected' );

# second link should be added
my $name_case_2          = "link002";
my $name_returned_case_2 = $obj->_store_feature( $obj->_link_feature_name(),
    ( map { $links{$name_case_2}{$_} } (qw(karyo start end strand)) ),
    $name_case_2 );

is( $name_returned_case_2, $name_case_2,
    'Correct name was returned for case 2' );
is_deeply( $obj->get_features(), $expected_case_2,
    'Reverse links are generated as expected' );

# third link should be added, but is identical to second link
my $name_case_3          = "link003";
my $name_returned_case_3 = $obj->_store_feature( $obj->_link_feature_name(),
    ( map { $links{$name_case_3}{$_} } (qw(karyo start end strand)) ),
    $name_case_3 );
is( $name_returned_case_3, $name_case_2,
    'Correct name was returned for case 3' );
is_deeply( $obj->get_features(), $expected_case_2,
    'Identical links are ignored and correct name is returned' );

done_testing;
