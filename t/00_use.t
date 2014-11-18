use Test::More;

use_ok('VIC');

can_ok('VIC', 'compile');
can_ok('VIC', 'assemble');

use_ok('t::TestVIC');

can_ok('t::TestVIC', 'compiles_ok');

can_ok('t::TestVIC', 'compile_fails_ok');

can_ok('t::TestVIC', 'assembles_ok');

can_ok('VIC', 'supported_chips');

can_ok('VIC', 'supported_simulators');

can_ok('VIC', 'is_chip_supported');

can_ok('VIC', 'list_chip_features');

can_ok('VIC', 'gputils');
note(join("\n", VIC::gputils()), "\n");

can_ok('VIC', 'gpasm');
note(VIC::gpasm(), "\n");
can_ok('VIC', 'gplink');
note(VIC::gplink(), "\n");

my $chips = VIC::supported_chips();
isa_ok($chips, 'ARRAY');
note(join(",", @$chips), "\n");
foreach my $c (@$chips) {
    if ($c =~ /X/) {
        my $ac = $c;
        $ac =~ s/X/4/g;
        is(VIC::is_chip_supported($ac), 1, "$ac is supported");
    } else {
        is(VIC::is_chip_supported($c), 1, "$c is supported");
    }
}
isnt(VIC::is_chip_supported("P16F1245"), 1, "P16F1245 is not supported");

my $sims = VIC::supported_simulators();
isa_ok($sims, 'ARRAY');
note(join(",", @$sims), "\n");

done_testing();
