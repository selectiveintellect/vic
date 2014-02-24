package VIC::Grammar;
use strict;
use warnings;

our $VERSION = '0.03';
$VERSION = eval $VERSION;

use Pegex::Base;
extends 'Pegex::Grammar';

use constant file => './share/vic.pgx';

sub make_tree {
  {
    '+grammar' => 'vic',
    '+toprule' => 'program',
    '+version' => '0.0.5',
    'COMMA' => {
      '.rgx' => qr/\G,/
    },
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
    '_' => {
      '.rgx' => qr/\G[\ \t]*/
    },
    '__' => {
      '.rgx' => qr/\G[\ \t]+/
    },
    'assign_operator' => {
      '.rgx' => qr/\G((?:\+|\-|%|\^|\*|\||&|\/)?=)/
    },
    'bit_operator' => {
      '.rgx' => qr/\G(\||\^|&)/
    },
    'blank_line' => {
      '.all' => [
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'EOL'
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
    'compare_operator' => {
      '.rgx' => qr/\G((?:!|=|<|>)=|(?:<|>))/
    },
    'comparison' => {
      '.all' => [
        {
          '.ref' => 'expr_value'
        },
        {
          '.ref' => 'compare_operator'
        },
        {
          '.ref' => 'expr_value'
        }
      ]
    },
    'complement' => {
      '.all' => [
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'complement_operator'
        },
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'variable'
        },
        {
          '.ref' => '_'
        }
      ]
    },
    'complement_operator' => {
      '.rgx' => qr/\G(\~|!)/
    },
    'conditional' => {
      '.all' => [
        {
          '.ref' => 'conditional_subject'
        },
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'COMMA'
        },
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'conditional_predicate'
        }
      ]
    },
    'conditional_predicate' => {
      '.any' => [
        {
          '.ref' => 'conditional_predicate_double'
        },
        {
          '.ref' => 'conditional_predicate_single'
        }
      ]
    },
    'conditional_predicate_double' => {
      '.all' => [
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'block'
        },
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'COMMA'
        },
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'block'
        },
        {
          '.ref' => '_'
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
    'conditional_predicate_single' => {
      '.all' => [
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'block'
        },
        {
          '.ref' => '_'
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
    'conditional_subject' => {
      '+min' => 0,
      '.ref' => 'single_conditional',
      '.sep' => {
        '.ref' => 'logic_operator'
      }
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
          '.ref' => '_'
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
          '.ref' => '_'
        }
      ]
    },
    'double_quoted_string' => {
      '.rgx' => qr/\G(?:"((?:[^\n\\"]|\\"|\\\\|\\[0nt])*?)")/
    },
    'end_block' => {
      '.all' => [
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'RCURLY'
        },
        {
          '.ref' => '_'
        },
        {
          '+max' => 1,
          '.ref' => 'EOL'
        }
      ]
    },
    'expr_value' => {
      '.all' => [
        {
          '.ref' => '_'
        },
        {
          '.any' => [
            {
              '.ref' => 'number'
            },
            {
              '.ref' => 'variable'
            },
            {
              '.ref' => 'number_units'
            },
            {
              '.ref' => 'complement'
            }
          ]
        },
        {
          '.ref' => '_'
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
        },
        {
          '.ref' => 'conditional'
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
    'incdec_operator' => {
      '.rgx' => qr/\G(\+\+|\-\-)/
    },
    'instruction' => {
      '.all' => [
        {
          '.ref' => 'name'
        },
        {
          '.ref' => 'values'
        },
        {
          '.ref' => '_'
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
          '.ref' => '_'
        },
        {
          '.ref' => 'variable'
        },
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'incdec_operator'
        },
        {
          '.ref' => '_'
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
          '.ref' => '_'
        },
        {
          '.ref' => 'variable'
        },
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'assign_operator'
        },
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'rhs_expr'
        },
        {
          '.ref' => '_'
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
    'logic_operator' => {
      '.rgx' => qr/\G((?:&|\|){2})/
    },
    'math_operator' => {
      '.rgx' => qr/\G(\+|\-|\*|\/|%)/
    },
    'name' => {
      '.all' => [
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'identifier'
        },
        {
          '.ref' => '_'
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
          '.ref' => '_'
        },
        {
          '.ref' => 'units'
        }
      ]
    },
    'op_rhs' => {
      '.all' => [
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'incdec_operator'
        },
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'variable'
        },
        {
          '.ref' => '_'
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
    'rhs_expr' => {
      '+min' => 0,
      '.ref' => 'expr_value',
      '.sep' => {
        '.ref' => 'rhs_operator'
      }
    },
    'rhs_operator' => {
      '.any' => [
        {
          '.ref' => 'math_operator'
        },
        {
          '.ref' => 'bit_operator'
        }
      ]
    },
    'single_conditional' => {
      '.any' => [
        {
          '.ref' => 'comparison'
        },
        {
          '.ref' => 'complement'
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
          '.ref' => '_'
        },
        {
          '.ref' => 'LCURLY'
        },
        {
          '.ref' => '_'
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
          '.ref' => '__'
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
      '.rgx' => qr/\G(s|ms|us|kHz|Hz|MHz)/
    },
    'validated_variable' => {
      '.ref' => 'identifier'
    },
    'value' => {
      '.all' => [
        {
          '.ref' => '_'
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
            },
            {
              '.ref' => 'validated_variable'
            }
          ]
        },
        {
          '.ref' => '_'
        }
      ]
    },
    'values' => {
      '+min' => 0,
      '.ref' => 'value',
      '.sep' => {
        '.ref' => 'COMMA'
      }
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
