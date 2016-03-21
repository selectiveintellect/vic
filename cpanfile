requires 'Capture::Tiny';
requires 'File::ShareDir', '1.00';
requires 'File::Spec';
requires 'File::Which';
requires 'Getopt::Long';
requires 'List::MoreUtils';
requires 'List::Util';
requires 'Moo', '1.003';
requires 'Pegex', '0.60';
requires 'namespace::clean';
requires 'perl', 'v5.14.0';
recommends 'App::Prove';
recommends 'XXX';
recommends 'Alien::gputils', '0.07';

on build => sub {
    requires 'File::Spec';
    requires 'File::Which';
    requires 'Module::Build';
    requires 'Pegex', '0.60';
    requires 'Test::More';
};
