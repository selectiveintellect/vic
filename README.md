VIC
===

VIC is a nice syntax that compiles to PIC assembly.

#Dependencies

This module depends on the following:

- `XXX` (temporary for debugging)
- `Pegex` (this is stored as a submodule `pegex-pm`)

#Updating dependencies

When you clone this repo for the first time you will need to do the following:

    $ git submodule init
    $ git submodule update

If you want to just update the submodule with a more recent version:

    $ git submodule update


#Testing

To test you will need to have `App::Prove` installed.

    $ prove -lv t

#Vim Syntax

The `vim` syntax for VIC is in `share/vic.vim`. You can place it in
`$HOME/.vim/syntax` on Linux and OS X and in `$HOME/vimfiles/syntax` on Windows
systems.

#How to write VIC programs

Documentation coming soon...

#Recompiling the grammar

This is for VIC developers only.

To recompile the grammar into `lib/VIC/Grammar.pm` run,

    $ PERL5LIB=$PWD/pegex-pm/lib:$PERL5LIB perl -Ilib -MVIC::Grammar=compile

#Contributors

- Vikas N Kumar @vikasnkumar
- Ingy @ingydotnet

#Copyright

Copyright: 2014. Vikas N Kumar. All Rights Reserved.
LICENSE: refer LICENSE file in the repository.


