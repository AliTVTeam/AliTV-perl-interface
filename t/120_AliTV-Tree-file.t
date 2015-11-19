use strict;
use warnings;

use Test::More;
use Test::Exception;

eval { use Test::Warnings ':all' };

plan skip_all => "Test::Warnings required for testing for warnings"
  if $@;

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

# I will not test, if the trees are correctly imported, as this should be guaranteed by Bioperl

# But check if the warning message will appear if multiple trees are inside the input file

my $warning = warning { $obj->file('data/multiple_trees.newick') };
like(
    $warning,
    qr/Multiple trees seems to be present in tree file/,
'Expecting warning from file method if multiple trees are inside the input file',
) || diag 'got warning(s) : ', explan($warning);

# the single tree files should give no warnings

foreach my $inputfile (@filelist) {
    my $warning = warning { $obj->file('data/multiple_trees.newick') };
    had_no_warnings( 'Import produced no warnings for ' . $inputfile );
}

done_testing;
