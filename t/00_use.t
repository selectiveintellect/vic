use Test::More;

use_ok('VIC');

can_ok('VIC', 'compile');

use_ok('t::TestVIC');

can_ok('t::TestVIC', 'compiles_ok');

can_ok('t::TestVIC', 'compile_fails_ok');

done_testing();
