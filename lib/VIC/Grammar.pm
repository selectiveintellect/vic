package VIC::Grammar;
use base 'Pegex::Grammar';

use constant text => <<'...';
%grammar vic
%version 0.0.1

program: statement*
statement: SPACE
...

1;
