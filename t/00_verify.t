use Test::More;
use_ok('VIC::PIC::Any');

can_ok('VIC::PIC::Any', 'supported_chips');
can_ok('VIC::PIC::Any', 'new');
can_ok('VIC::PIC::Any', 'new_simulator');
can_ok('VIC::PIC::Any', 'supported_simulators');
can_ok('VIC::PIC::Any', 'is_chip_supported');
can_ok('VIC::PIC::Any', 'is_simulator_supported');
can_ok('VIC::PIC::Any', 'list_chip_features');
can_ok('VIC::PIC::Any', 'print_pinout');
my $chips = VIC::PIC::Any::supported_chips();
isa_ok($chips, ref []);
ok(scalar(@$chips) > 0);
foreach my $chip (@$chips) {
    my $self = VIC::PIC::Any->new($chip);
    isnt($self, undef);
    isa_ok($self, 'VIC::PIC::' . uc($chip));
}
my $sims = VIC::PIC::Any::supported_simulators();
isa_ok($sims, ref []);
ok(scalar(@$sims) > 0);
foreach my $sim (@$sims) {
    my $self = VIC::PIC::Any->new_simulator(type => $sim);
    isnt($self, undef);
    isa_ok($self, 'VIC::PIC::' . ucfirst($sim));
}

done_testing();

