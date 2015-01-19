use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

pragma UART baud = 9600; # set baud rate

Main {
    digital_output UART; # set up USART for transmit
    write UART, "Hello World!";
}
...

my $output = <<'...';
...

compiles_ok($input, $output);
