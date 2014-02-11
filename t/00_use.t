use Test::More;

use lib 'pegex-pm/lib';

use_ok('VIC');

can_ok('VIC', 'compile');

use_ok('t::TestVIC');

can_ok('t::TestVIC', 'compiles_ok');

done_testing();
