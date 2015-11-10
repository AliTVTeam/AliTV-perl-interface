use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Seq') };

can_ok('AliTV::Seq', qw(seq));

my $obj = new_ok('AliTV::Seq');

# is the default id undef?
ok(! defined $obj->seq(), 'Empty object id is undef');

# empty the attribute
$obj->{_seq_obj} = "";
# this should cause an exception
throws_ok { $obj->seq(); }
	  qr/The sequence storage attribute is not a Bio::Seq object/,
          'Exception when using a not Bio::Seq attribute';

# as well as a missing attribute
delete $obj->{_seq_obj};
throws_ok { $obj->seq(); }
	  qr/The sequence storage attribute does not exist/,
          'Exception when using without an existing attribute';

my $new_seq = "ACGTTTGCGTG";
$obj = new_ok('AliTV::Seq');
ok($obj->id($new_seq) eq $new_seq, 'Setter/getter works as expected');

done_testing;
