use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Tree') }

can_ok( 'AliTV::Tree', qw(tree_2_json_structure _deep_scan) );

my $obj = new_ok('AliTV::Tree');

# import the expected values from __DATA__ section
my %expected = ();
while (<DATA>) {
    chomp;
    my ( $file, $expected_structure ) = split( /\s+/, $_, 2);
    my $for_eval = '$expected{$file} = ' . $expected_structure . ';';
    eval $for_eval;
    die "Error while importing the expected structures: $@" if ($@);
}

foreach my $inputfile ( keys %expected ) {
    $obj->file($inputfile);
    is_deeply( $obj->tree_2_json_structure(),
        $expected{$inputfile}, 'Expected tree strucutre for ' . $inputfile );
}

done_testing;

__DATA__
data/tree_a.newick { children => [ { name => 'a' }, { children => [ { name => 'b' }, { children => [ {name => 'c' }, { name => 'd' } ] } ] } ] }
