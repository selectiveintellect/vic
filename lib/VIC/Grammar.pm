package VIC::Grammar;
use base 'Pegex::Grammar';
use XXX;

use constant text => <<'...';
%grammar vic
%version 0.0.1

# uc-type is necessary.
program: uc-type header* statement*

header: uc-header | comment | blank-line
uc-type: /PIC <BLANK>+ (<ALNUM>+) <SEMI>? <EOL>/
uc-header: /set <UNDER> (config|org) <ANY>* <SEMI>? <EOL>/
comment: /<HASH> <ANY>* <EOL>/
blank-line: /<BLANK>* <EOL>/

statement: comment | block | instruction | end-block

#FIXME: Should <WORDS> be used here below ?
block: /<ALPHA>[<UNDER><ALNUM>]* - <LCURLY>/
end-block: /<RCURLY>/

instruction: name value* SEMI?

#FIXME: Should <WORDS> be used here below ?
name: /<ALPHA> [<ALNUM><UNDER>]*/
value: string | number | variable COMMA?
string: single-quoted-string | double-quoted-string
# most microcontrollers cannot do floating point math so ignore real numbers
number: integer | hexadecimal
integer: <DIGIT>+
hexadecimal: /0x<HEX>+/
variable: name

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
