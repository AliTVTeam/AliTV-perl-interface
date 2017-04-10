use strict;
use warnings;

use Test::More;
use Test::Exception;
use Data::Dumper;
use Bio::SeqIO;

BEGIN { use_ok('AliTV::Alignment::importer') }

can_ok( 'AliTV::Alignment::importer', qw(run) );

my $obj = new_ok('AliTV::Alignment::importer');

lives_ok { $obj->run(); } 'run can be called without exception';

done_testing;