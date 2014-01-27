package VIC::Grammar;
use strict;
use warnings;

use base 'Pegex::Grammar';
use XXX;

# use constant creates a function text that returns the string
# this is the same thing as needed by Pegex::Grammar
use constant text => <<'...';
%grammar vic
%version 0.0.1

# uc-type is necessary.
program: uc-type header* statement*

header: uc-header | comment
uc-type: /PIC <BLANK>+ (<uc-types>) <SEMI>? <EOL>/

# P16F690X is fake just to show how to enumerate.
uc-types: /(?i:P16F690 | P16F690X)/
uc-header: /set <UNDER> (config|org) <BLANK>* (<ANY>*) <SEMI>? <EOL>/
comment: /<HASH> <ANY>* <EOL>/ | blank-line
blank-line: whitespace* /<EOL>/
whitespace: /<BLANK>+/

statement: comment | block | instruction | end-block

block: name /<BLANK>* <LCURLY> <BLANK>*<EOL>?/
end-block: /<BLANK>* <RCURLY> <BLANK>* <EOL>?/

instruction: name values* <SEMI>?

name: whitespace* identifier whitespace*
values: (value /<COMMA>/)* value
value: whitespace* (string | number-units | number | variable) whitespace*

string: single-quoted-string | double-quoted-string

# most microcontrollers cannot do floating point math so ignore real numbers
number-units: number whitespace* units
number: integer | hexadecimal
integer: /(<DIGIT>+)/
hexadecimal: /(:0[xX])?(<HEX>+)/
units: /s | ms | us/

variable: <DOLLAR> identifier
identifier: /(<ALPHA>[<WORDS>]*)/

single_quoted_string:
    /(:
        <SINGLE>
        ((:
            [^<BREAK><BACK><SINGLE>] |
            <BACK><SINGLE> |
            <BACK><BACK>
        )*?)
        <SINGLE>
    )/

double_quoted_string:
    /(:
        <DOUBLE>
        ((:
            [^<BREAK><BACK><DOUBLE>] |
            <BACK><DOUBLE> |
            <BACK><BACK> |
            <BACK><escape>
        )*?)
        <DOUBLE>
    )/

escape: / [0nt] /
...

# Remove the X_ to debug the grammar
sub X_make_tree {
    my ($self) = @_;
    my $text = $self->text
        or die "Can't create a '" . ref($self) .
            "' grammar. No tree or text or file.";
    require Pegex::Compiler;
    local $ENV{PERL_PEGEX_DEBUG} = 1;
    return XXX + Pegex::Compiler->new->compile($text)->tree;
}

1;
