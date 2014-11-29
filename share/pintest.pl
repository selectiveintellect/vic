#!/usr/bin/env perl
use strict;
use warnings;
my $pins = {
    # number to pin name and pin name to number
    1 => [qw(Vdd)],
    2 => [qw(GP5 T1CKI OSC1 CLKIN)],
    3 => [qw(GP4 AN3 T1G OSC2 CLKOUT)],
    4 => [qw(GP3 MCLR Vpp)],
    5 => [qw(GP2 AN2 T0CKI INT COUT CCP1)],
    6 => [qw(GP1 AN1 CIN- Vref ICSPCLK)],
    7 => [qw(GP0 AN0 CIN+ ICSPDAT ULPWU)],
    8 => [qw(Vss)],
};
my $maxlen = 0;
my @pinnames = ();
foreach (sort(keys %$pins)) {
    my $str = join('/', @{$pins->{$_}});
    $pinnames[$_ - 1] = $str;
    $maxlen = length($str) if $maxlen < length($str);
}

my $pdip = scalar(@pinnames) / 2;
my $start = 5 + $maxlen;
my $chip = 'P12F683';
my $w = 14;
my $notch = '__';
my $w0 = ($w - length($notch)) / 2;
print ' ' x ($start + 2), '+', '=' x $w0, $notch, '=' x $w0, '+', "\n";
for (my $i = 0; $i < $pdip; ++$i) {
    my $s1 = $pinnames[$i];
    my $s2 = $pinnames[2 * $pdip - $i - 1];
    my $l1 = $start - 1 - length $s1;
    my $p1 = sprintf "%d", ($i + 1);
    my $p2 = sprintf "%d", (2 * $pdip - $i);
    my $w1 = $w - length($p1) - length($p2);
    print ' ' x $l1, $s1, ' ', '--', '|', $p1, ' ' x $w1, $p2, '|', '--', ' ',$s2, "\n";
    print ' ' x ($start + 2), '|', ' ' x $w, '|', "\n";
    if (($i + 1) == int($pdip / 2)) {
        my $w2 = int(($w - length($chip)) / 2);
        my $w3 = $w - $w2 - length($chip);
        print ' ' x ($start + 2), '|', ' ' x $w2, $chip, ' ' x $w3, '|', "\n";
        print ' ' x ($start + 2), '|', ' ' x $w, '|', "\n";
    }
}
print ' ' x ($start + 2), '+', '=' x $w, '+', "\n";
