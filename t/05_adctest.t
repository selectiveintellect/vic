use lib 'pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

Main {
    digital_output RC0;
    analog_input RA0;
    # adc_setup clock, channel
    adc_enable 500kHz, AN0;
    Loop {
        adc_read $display;
        delay_ms $display;
        write RC0, 1;
        delay_ms $display;
        write RC0, 0;
        delay 100us;
    }
}
...

my $output = <<'...';
...

compiles_ok($input, $output);
