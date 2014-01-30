use Test::More;

use lib 'pegex-pm/lib', '../pegex-pm/lib';

use_ok('VIC');

can_ok('VIC', 'compile');

use_ok('Test::VIC');

can_ok('Test::VIC', 'compiles_ok');

done_testing();
