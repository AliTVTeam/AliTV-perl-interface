use strict;
use warnings;

use Test::More;
BEGIN { use_ok('AliTV::Script') };

can_ok('AliTV::Script', qw(run));

AliTV::Script->run(qw(data/vectors/M13mp18.fasta  data/vectors/pBluescribeKSPlus.fasta  data/vectors/pBR322.fasta  data/vectors/pUC19.fasta  data/vectors/vectors.fasta));

done_testing;