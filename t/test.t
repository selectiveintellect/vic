use Test::More tests => 1;

use lib '../pegex-pm/lib';

my $input = <<'...';
PIC p16f690

set_config

# A Comment

set_org 0

Main {
    output_port 'C', 0
    Loop {
        port_value 'C', 1
        delay 1s
        port_value 'C', 0
        delay 1s
    }
}
...

my $output = <<'...';
...

use VIC;
$ENV{PERL_PEGEX_DEBUG} = 1;

is VIC::compile($input), $output;
