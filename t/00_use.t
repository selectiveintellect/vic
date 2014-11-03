use Test::More;

use_ok('VIC');

can_ok('VIC', 'compile');

use_ok('t::TestVIC');

can_ok('t::TestVIC', 'compiles_ok');

can_ok('t::TestVIC', 'compile_fails_ok');

can_ok('VIC', 'supported_chips');

can_ok('VIC', 'supported_simulators');

my $chips = VIC::supported_chips();
isa_ok($chips, 'ARRAY');
note(join(",", @$chips), "\n");

my $sims = VIC::supported_simulators();
isa_ok($sims, 'ARRAY');
note(join(",", @$sims), "\n");

done_testing();
