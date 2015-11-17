use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Base') };
local *AliTV::Base::_initialize = sub {};

my @methods_wo_exception = qw(_debug _info _warn _error _fatal _logwarn);
my @methods_exception = qw(_logdie);

can_ok('AliTV::Base', qw(_logging));
can_ok('AliTV::Base', @methods_wo_exception);
can_ok('AliTV::Base', @methods_exception);

# if called as class method all methods should result in an exception
foreach my $method (@methods_wo_exception, @methods_exception)
{
    throws_ok { AliTV::Base->$method($method) } qr/$method/,
        'Logging as class method results in an exception for method: '.$method;
}

my $obj = new_ok('AliTV::Base');

# if called as object method most methods should result in no exception
foreach my $method (@methods_wo_exception)
{
    lives_ok { $obj->$method($method) } 
        'Logging as object method results in no exception for method: '.$method;
}

# but some methods need to create an exception
foreach my $method (@methods_exception)
{
    throws_ok { $obj->$method($method) } qr/$method/,
        'Logging as object method results in an exception for method: '.$method;
}

done_testing;
