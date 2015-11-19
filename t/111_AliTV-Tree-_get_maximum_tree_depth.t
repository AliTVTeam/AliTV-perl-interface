use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Tree') }

can_ok( 'AliTV::Tree', qw(_get_maximum_tree_depth) );

my $obj = new_ok('AliTV::Tree');

# import the expected values from __DATA__ section
my %expected = ();
while (<DATA>) {
    chomp;
    my ( $file, $expected_depth ) = split( /\s+/, $_ );
    $expected{$file} = $expected_depth;
}

foreach my $inputfile ( keys %expected ) {
    $obj->file($inputfile);
    is( $obj->_get_maximum_tree_depth(),
        $expected{$inputfile}, 'Expected tree depth for ' . $inputfile );
}

done_testing;

__DATA__
data/tree_a.newick 3
data/tree_b.newick 2
data/tree_c.newick 6
