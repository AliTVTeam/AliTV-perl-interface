use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Tree') }

# this test is not required as it always has a file method
can_ok( 'AliTV::Tree', qw(file) );

my $obj = new_ok('AliTV::Tree');

my @filelist = qw(data/tree_a.newick data/tree_b.newick data/tree_c.newick);

foreach my $inputfile (@filelist) {
    $obj->file($inputfile);
    isa_ok( $obj->{_tree}, "Bio::Tree::TreeI",
        'Import results in an Bio::Tree::TreeI object for ' . $inputfile );
}

done_testing;
