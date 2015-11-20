use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Warnings ':all';

BEGIN { use_ok('AliTV::Tree') }

can_ok( 'AliTV::Tree', qw(check_4_leaf_nodes) );

my $obj = new_ok('AliTV::Tree');

# import a simple tree
my $inputfile = "data/tree_a.newick";

$obj->file($inputfile);

my %testset = (
    correct           => [qw(a b c d)],
    generates_warning => [qw(a b c)],
    should_die        => [qw(a b c d e)]
);

# run through the test sets
foreach my $set ( keys %testset ) {

    # first test for an exception
    if ( $set =~ /die/ ) {
        throws_ok { $obj->check_4_leaf_nodes( @{ $testset{$set} } ) }
        qr/Required species are not present in the given species set/,
          "Missing species result in an exception for data set '$set'";

        # we are done
        next;
    }

    # no exception must be generated
    lives_ok { $obj->check_4_leaf_nodes( @{ $testset{$set} } ) }
    "No exception has been generated for data set '$set'";

    # first test for an exception
    if ( $set =~ /warning/ ) {
        my $warning =
          warning { $obj->check_4_leaf_nodes( @{ $testset{$set} } ) };
        like(
            $warning,
            qr/Tree contains species which are not required! Ignoring!/,
"Expecting warning with more than the expected species in our tree for set '$set'",
        ) || diag 'got warning(s) : ', explain($warning);

        # we are done
        next;
    }

    # no warning must be generated
    $obj->check_4_leaf_nodes( @{ $testset{$set} } );
    had_no_warnings("No warning has been generated for data set '$set'");

    ok( $obj->check_4_leaf_nodes( @{ $testset{$set} } ),
        "Test succeeds for data set '$set'" );
}

done_testing;
