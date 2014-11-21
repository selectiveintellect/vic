use strict;
use warnings;
use Module::Build;

my %pl_files = ();
%pl_files = ( PL_files => { 'share/rebuild-grammar.PL' => [] } ) if $ENV{DEVELOPER};
my %gputils = ( 'Alien::gputils' => 0.07 );
my %linux = $^O =~ /linux/i ? %gputils : ();
my %nonlinux = $^O !~ /linux/i ? %gputils : ();
my $build = Module::Build->new(
    module_name => 'VIC',
    license => 'perl',
    dist_author => 'Vikas N. Kumar <vikas@cpan.org>',
    dist_abstract => 'VIC is a high level syntax to generate PIC microcontroller assembly',
    dist_version_from => 'lib/VIC.pm',
    create_readme => 0,
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Module::Build' => 0,
        'Test::More' => 0,
        'File::Spec' => 0,
        'File::Which' => 0,
        'Pegex' => 0.55, # needed for PL_files to work
        'strictures' => 0,
        'indirect' => 0,
        'multidimensional' => 0,
        'bareword::filehandles' => 0,
    },
    requires => {
        'Getopt::Long' => 0,
        'Capture::Tiny' => 0,
        'File::Spec' => 0,
        'File::Which' => 0,
        'Pegex' => 0.55, # needed for PL_files to work
        'List::Util' => 0,
        'List::MoreUtils' => 0,
        'Moo' => 0,
        'namespace::clean' => 0,
        %linux,
    },
    recommends => {
        'XXX' => 0,
        'App::Prove' => 0,
        %nonlinux,
    },
    share_dir => 'share',
    dynamic_config => 1,
    add_to_cleanup => [ qw/*.bak/ ],
    meta_merge => {
        resources => {
            repository => 'https://github.com/selectiveintellect/vic',
            bugtracker => 'https://github.com/selectiveintellect/vic/issues',
            x_IRC => 'irc://irc.freenode.net/#vic',
            x_Twitter => 'https://twitter.com/_vicash_',
        },
        keywords => [qw/VIC PIC assembly/],
        no_index => {
            directory => [qw/ t /],
        },
    },
    %pl_files,
);

$build->create_build_script;
$build->dispatch('clean');
$build->dispatch('distmeta');
$build->dispatch('manifest');

__END__
#### COPYRIGHT: 2014. Vikas N Kumar. All Rights Reserved
#### AUTHOR: Vikas N Kumar <vikas@cpan.org>
#### DATE: 5th Feb 2014
#### LICENSE: Refer LICENSE file.
