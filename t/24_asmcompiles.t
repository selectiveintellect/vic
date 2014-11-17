use t::TestVIC;

my $input = <<'...';
PIC PIC16F690;

# A Comment

Main { # set the Main function
     digital_output RA0; # mark pin RA0 as output
     write RA0, 1; # write the value 1 to RA0
} # end the Main function
...

compiles_asm_ok($input, 'pic16f690');

done_testing();
