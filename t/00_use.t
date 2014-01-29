use Test::More;

use lib 'pegex-pm/lib', '../pegex-pm/lib';

BEGIN { use_ok('VIC'); }

can_ok('VIC', 'compile');

done_testing();
