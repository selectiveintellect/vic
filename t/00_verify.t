use Test::More;
use_ok('VIC::PIC::Any');

can_ok( 'VIC::PIC::Any', 'supported_chips' );
can_ok( 'VIC::PIC::Any', 'new' );
can_ok( 'VIC::PIC::Any', 'new_simulator' );
can_ok( 'VIC::PIC::Any', 'supported_simulators' );
can_ok( 'VIC::PIC::Any', 'is_chip_supported' );
can_ok( 'VIC::PIC::Any', 'is_simulator_supported' );
can_ok( 'VIC::PIC::Any', 'list_chip_features' );
can_ok( 'VIC::PIC::Any', 'print_pinout' );
my $chips = VIC::PIC::Any::supported_chips();
isa_ok( $chips, ref [] );
ok( scalar(@$chips) > 0 );

foreach my $chip (@$chips) {
    subtest $chip => sub {
        my $self = VIC::PIC::Any->new($chip);
        isnt( $self, undef );
        isa_ok( $self, 'VIC::PIC::' . uc($chip) );
        can_ok($self, qw/list_roles chip_config print_pinout doesrole doesroles/);
        my $roles = $self->list_roles;
        isa_ok($roles, ref []);
        isa_ok($self->chip_config, ref {});
        isa_ok($self->memory, ref {});
        isa_ok($self->address, ref {});
        isa_ok($self->pin_counts, ref {});
        isa_ok($self->banks, ref {});
        isa_ok($self->registers, ref {});
        isa_ok($self->pins, ref {});
        isa_ok($self->clock_pins, ref {});
        isa_ok($self->oscillator_pins, ref {});
        isa_ok($self->program_pins, ref {});
        isnt($self->program_pins->{clock}, undef);
        isnt($self->program_pins->{data}, undef);
        done_testing();
    };
}
my $sims = VIC::PIC::Any::supported_simulators();
isa_ok( $sims, ref [] );
ok( scalar(@$sims) > 0 );
foreach my $sim (@$sims) {
    subtest $sim => sub {
        my $self = VIC::PIC::Any->new_simulator( type => $sim );
        isnt( $self, undef );
        isa_ok( $self, 'VIC::PIC::' . ucfirst($sim) );
        can_ok($self, qw/type include pic supports_modifier init_code attach_led
            attach_led7seg stop_after logfile log scope sim_assert stimulate
            attach autorun stopwatch get_autorun_code disable/);
        done_testing();
    };
}

done_testing();

