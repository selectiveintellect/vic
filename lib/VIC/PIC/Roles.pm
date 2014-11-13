use strict;
use warnings;

package VIC::PIC::Roles::CodeGen;
{
    use Moo::Role;
    requires qw(type org include chip_config code_config
      validate validate_modifier_operator update_code_config
    );
}

package VIC::PIC::Roles::Operators;
{
    use Moo::Role;
    requires qw(
      op_assign op_assign_wreg rol ror op_shl op_shr shl shr op_not
      op_comp op_add_assign_literal op_add_assign op_sub_assign
      op_mul_assign op_div_assign op_mod_assign op_bxor_assign
      op_band_assign op_bor_assign op_shl_assign op_shr_assign
      op_inc op_dec op_add op_sub op_mul op_div op_mod op_bxor
      op_band op_bor op_eq op_lt op_ge op_ne op_le op_gt op_and
      op_or op_sqrt
    );
}

package VIC::PIC::Roles::Chip;
{
    use Moo::Role;

    requires qw(f_osc pcl_size stack_size wreg_size
      memory address banks registers address_bits
      pins);

    # useful for checking if a chip is PDIP or SOIC or SSOP or QFN
    # maybe extracted to a separate role defining chip type but not yet
    requires qw(pin_counts);
}

package VIC::PIC::Roles::GPIO;
{
    use Moo::Role;

    # input_pins is a list of input pins.
    # output pins is a list of output pins.
    # Bi-directional pins will be in both lists
    # analog_pins are a list of analog_pins
    requires qw(input_pins output_pins io_ports
      analog_pins get_input_pin get_output_pin);
    requires qw(digital_output digital_input analog_input write);
}

package VIC::PIC::Roles::ADC;
{
    use Moo::Role;

    requires qw(adc_enable adc_disable adc_read adc_channels adcs_bits
    adc_chs_bits);
}

package VIC::PIC::Roles::Timer;
{
    use Moo::Role;
}

package VIC::PIC::Roles::CCP;
{
    use Moo::Role;
    requires qw(ccp_pins);
}

package VIC::PIC::Roles::Operations;
{
    use Moo::Role;
    requires qw(delay delay_ms delay_us delay_s debounce);
}

1;
__END__
