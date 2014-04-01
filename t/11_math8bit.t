use lib 'ext/pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

config variable bits = 8;

Main {
    $var1 = 12345;
    $var2 = 113;
    $var3 = $var2 * $var1;
    $var3 = $var2 + $var1;
    $var3 = $var2 - $var1;
    $var3 = $var2 / $var1;
    $var3 = $var2 % $var1;
    --$var3;
    ++$var3;
    $var4 = 64;
    # sqrt is a modifier
    #$var3 = sqrt $var4;
    #$var5 = ($var1 + (($var3 * ($var4 + $var7) + 5) + $var2));
}
...

my $output = << '...';
...

#compiles_ok($input, $output);
compile_fails_ok($input);
