use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    module_name => 'VIC',
    license => 'perl',
    dist_author => 'Vikas N. Kumar <vikas@cpan.org>',
    dist_abstract => 'VIC is a high level syntax to generate PIC microcontroller assembly',
    dist_version_from => 'lib/VIC.pm',
    create_readme => 0,
    create_license => 0,
    configure_requires => {
        'Module::Build' => 0,
        'Software::License' => 0,
    },
    build_requires => {
        'Module::Build' => 0,
        'Test::More' => 0,
        'File::Spec' => 0,
        'Pegex' => 0.55, # needed for PL_files to work
        'strictures' => 0,
        'indirect' => 0,
        'multidimensional' => 0,
        'bareword::filehandles' => 0,
    },
    requires => {
        'Getopt::Long' => 0,
        'File::Spec' => 0,
        'Pegex' => 0.55, # needed for PL_files to work
        'List::Util' => 0,
        'List::MoreUtils' => 0,
        'Moo' => 0,
        'namespace::clean' => 0,
    },
    recommends => {
        'XXX' => 0,
        'App::Prove' => 0,
    },
    share_dir => 'share',
    dynamic_config => 1,
    add_to_cleanup => [ qw/*.bak/ ],
    meta_merge => {
        resources => {
            repository => 'https://github.com/selectiveintellect/vic',
            bugtracker => 'https://github.com/selectiveintellect/vic/issues',
            x_IRC => 'irc://irc.freenode.net/#vic',
            x_twitter => 'https://twitter.com/_vicash_',
        },
        keywords => [qw/VIC PIC assembly/],
        no_index => {
            directory => [qw/ t /],
            namespace => ['VIC::PIC::Roles', 'VIC::PIC::Functions'],
        },
    },
    PL_files => { 'share/rebuild-grammar.PL' => [] },
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
