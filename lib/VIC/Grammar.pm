package VIC::Grammar;
use strict;
use warnings;

our $VERSION = '0.02';
$VERSION = eval $VERSION;

use base 'Pegex::Grammar';

use constant file => './share/vic.pgx';

sub make_tree {
  {
    '+grammar' => 'vic',
    '+toprule' => 'program',
    '+version' => '0.0.3',
    'DOLLAR' => {
      '.rgx' => qr/\G\$/
    },
    'EOL' => {
      '.rgx' => qr/\G\r?\n/
    },
    'EOS' => {
      '.rgx' => qr/\G\z/
    },
    'EQUAL' => {
      '.rgx' => qr/\G=/
    },
    'LCURLY' => {
      '.rgx' => qr/\G\{/
    },
    'RCURLY' => {
      '.rgx' => qr/\G\}/
    },
    'SEMI' => {
      '.rgx' => qr/\G;/
    },
    'blank_line' => {
      '.all' => [
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '.rgx' => qr/\G\r?\n/
        }
      ]
    },
    'block' => {
      '.all' => [
        {
          '.ref' => 'start_block'
        },
        {
          '+min' => 0,
          '.ref' => 'statement'
        },
        {
          '.ref' => 'end_block'
        }
      ]
    },
    'comment' => {
      '.any' => [
        {
          '.rgx' => qr/\G[\ \t]*\#.*\r?\n/
        },
        {
          '.ref' => 'blank_line'
        }
      ]
    },
    'config_expression' => {
      '.all' => [
        {
          '.ref' => 'name'
        },
        {
          '.ref' => 'EQUAL'
        },
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '.any' => [
            {
              '.ref' => 'number_units'
            },
            {
              '.ref' => 'number'
            }
          ]
        },
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        }
      ]
    },
    'double_quoted_string' => {
      '.rgx' => qr/\G(?:"((?:[^\n\\"]|\\"|\\\\|\\[0nt])*?)")/
    },
    'end_block' => {
      '.all' => [
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '.ref' => 'RCURLY'
        },
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '+max' => 1,
          '.ref' => 'EOL'
        }
      ]
    },
    'expression' => {
      '.any' => [
        {
          '.ref' => 'lhs_op_rhs'
        },
        {
          '.ref' => 'lhs_op'
        },
        {
          '.ref' => 'op_rhs'
        }
      ]
    },
    'header' => {
      '.any' => [
        {
          '.ref' => 'uc_config'
        },
        {
          '.ref' => 'comment'
        }
      ]
    },
    'identifier' => {
      '.rgx' => qr/\G([a-zA-Z][0-9A-Za-z_]*)/
    },
    'instruction' => {
      '.all' => [
        {
          '.ref' => 'name'
        },
        {
          '+min' => 0,
          '.ref' => 'values'
        },
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '.ref' => 'SEMI'
        },
        {
          '+max' => 1,
          '.ref' => 'EOL'
        }
      ]
    },
    'lhs_op' => {
      '.all' => [
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '.ref' => 'variable'
        },
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '.ref' => 'operator'
        },
        {
          '+max' => 1,
          '.ref' => 'SEMI'
        },
        {
          '+max' => 1,
          '.ref' => 'EOL'
        }
      ]
    },
    'lhs_op_rhs' => {
      '.all' => [
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '.ref' => 'variable'
        },
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '.ref' => 'operator'
        },
        {
          '.ref' => 'value'
        },
        {
          '.ref' => 'SEMI'
        },
        {
          '+max' => 1,
          '.ref' => 'EOL'
        }
      ]
    },
    'name' => {
      '.all' => [
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '.ref' => 'identifier'
        },
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        }
      ]
    },
    'number' => {
      '.rgx' => qr/\G(0x[0-9a-fA-F]+|0X[0-9a-fA-F]+|[0-9]+)/
    },
    'number_units' => {
      '.all' => [
        {
          '.ref' => 'number'
        },
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '.ref' => 'units'
        }
      ]
    },
    'op_rhs' => {
      '.all' => [
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '.ref' => 'operator'
        },
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '.ref' => 'variable'
        },
        {
          '+max' => 1,
          '.ref' => 'SEMI'
        },
        {
          '+max' => 1,
          '.ref' => 'EOL'
        }
      ]
    },
    'operator' => {
      '.rgx' => qr/\G((?:!|=|%|\^|&|\*|\~|\-|\+|\||\/|<|>){1,2})/
    },
    'program' => {
      '.all' => [
        {
          '.ref' => 'uc_select'
        },
        {
          '+min' => 0,
          '.ref' => 'header'
        },
        {
          '+min' => 0,
          '.ref' => 'statement'
        },
        {
          '.ref' => 'EOS'
        }
      ]
    },
    'single_quoted_string' => {
      '.rgx' => qr/\G(?:'((?:[^\n\\']|\\'|\\\\)*?)')/
    },
    'start_block' => {
      '.all' => [
        {
          '.ref' => 'name'
        },
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '.ref' => 'LCURLY'
        },
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '+max' => 1,
          '.ref' => 'EOL'
        }
      ]
    },
    'statement' => {
      '.any' => [
        {
          '.ref' => 'comment'
        },
        {
          '.ref' => 'instruction'
        },
        {
          '.ref' => 'expression'
        },
        {
          '.ref' => 'block'
        }
      ]
    },
    'string' => {
      '.any' => [
        {
          '.ref' => 'single_quoted_string'
        },
        {
          '.ref' => 'double_quoted_string'
        }
      ]
    },
    'uc_config' => {
      '.all' => [
        {
          '.rgx' => qr/\Gconfig/
        },
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '.ref' => 'name'
        },
        {
          '.ref' => 'config_expression'
        },
        {
          '.ref' => 'SEMI'
        },
        {
          '.ref' => 'EOL'
        }
      ]
    },
    'uc_select' => {
      '.rgx' => qr/\GPIC[\ \t]+((?i:P16F690|P16F690X));\r?\n/
    },
    'units' => {
      '.rgx' => qr/\G(s|ms|us)/
    },
    'value' => {
      '.all' => [
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        },
        {
          '.any' => [
            {
              '.ref' => 'string'
            },
            {
              '.ref' => 'number_units'
            },
            {
              '.ref' => 'number'
            },
            {
              '.ref' => 'variable'
            },
            {
              '.ref' => 'block'
            }
          ]
        },
        {
          '+min' => 0,
          '.ref' => 'whitespace'
        }
      ]
    },
    'value_comma' => {
      '.all' => [
        {
          '.ref' => 'value'
        },
        {
          '.rgx' => qr/\G,/
        }
      ]
    },
    'values' => {
      '.all' => [
        {
          '+min' => 0,
          '.ref' => 'value_comma'
        },
        {
          '.ref' => 'value'
        }
      ]
    },
    'variable' => {
      '.all' => [
        {
          '.ref' => 'DOLLAR'
        },
        {
          '.ref' => 'identifier'
        }
      ]
    },
    'whitespace' => {
      '.rgx' => qr/\G[\ \t]+/
    }
  }
}

1;

=encoding utf8

=head1 NAME

VIC::Grammar

=head1 SYNOPSIS

The Pegex::Grammar class for handling the grammar.

=head1 DESCRIPTION

INTERNAL CLASS. THIS IS AUTO-GENERATED. DO NOT EDIT.

=head1 AUTHOR

Vikas N Kumar <vikas@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2014. Vikas N Kumar

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
