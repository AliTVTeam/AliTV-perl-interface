use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Alignment') }

can_ok( 'AliTV::Alignment', qw(export_to_genome) );

# without callback
my $obj = new_ok('AliTV::Alignment');

$obj->import_alignments(@input_files);

throws_ok { $obj->export_to_genome() } qr/Callback needs to be specified/, 'Exception without callback function';

done_testing;
