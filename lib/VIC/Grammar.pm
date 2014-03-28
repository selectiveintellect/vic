package VIC::Grammar;
use strict;
use warnings;

our $VERSION = '0.04';
$VERSION = eval $VERSION;

use Pegex::Base;
extends 'Pegex::Grammar';

use constant file => './share/vic.pgx';

sub make_tree {
  {
    '+grammar' => 'vic',
    '+toprule' => 'program',
    '+version' => '0.0.7',
    'COMMA' => {
      '.rgx' => qr/\G,/
    },
    'DOLLAR' => {
      '.rgx' => qr/\G\$/
    },
    'EOS' => {
      '.rgx' => qr/\G\z/
    },
    '_' => {
      '.rgx' => qr/\G[\ \t]*/
    },
    '__' => {
      '.rgx' => qr/\G[\ \t]+/
    },
    'anonymous_block' => {
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
    'assign_expr' => {
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
        }
      ]
    },
    'assign_operator' => {
      '.rgx' => qr/\G([\+\-%\^\*\|&\/]?=)/
    },
    'bit_operator' => {
      '.rgx' => qr/\G([\|\^&])/
    },
    'blank_line' => {
      '.rgx' => qr/\G[\ \t]*\r?\n/
    },
    'block' => {
      '.any' => [
        {
          '.ref' => 'named_block'
        },
        {
          '.ref' => 'conditional_block'
        }
      ]
    },
    'boolean' => {
      '.rgx' => qr/\G(TRUE|FALSE|true|false|0|1)/
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
      '.rgx' => qr/\G([!=<>]=|(?:<|>))/
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
          '.ref' => 'rhs_expr'
        },
        {
          '.ref' => '_'
        }
      ]
    },
    'complement_operator' => {
      '.rgx' => qr/\G(\~|!)/
    },
    'conditional_block' => {
      '.all' => [
        {
          '.ref' => '_'
        },
        {
          '.rgx' => qr/\Gwhile|until/
        },
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'conditional_subject'
        },
        {
          '.ref' => 'anonymous_block'
        }
      ]
    },
    'conditional_predicate' => {
      '.all' => [
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'anonymous_block'
        },
        {
          '.ref' => '_'
        },
        {
          '+max' => 1,
          '.ref' => 'COMMA'
        },
        {
          '.ref' => '_'
        },
        {
          '+min' => 0,
          '.any' => [
            {
              '.ref' => 'anonymous_block'
            },
            {
              '.ref' => 'conditional_statement'
            }
          ]
        },
        {
          '.ref' => '_'
        }
      ]
    },
    'conditional_statement' => {
      '.all' => [
        {
          '.ref' => '_'
        },
        {
          '.rgx' => qr/\Gif/
        },
        {
          '.ref' => '_'
        },
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
    'conditional_subject' => {
      '+min' => 1,
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
          '.rgx' => qr/\G=[\ \t]*/
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
      '.rgx' => qr/\G[\ \t]*\}[\ \t]*\r?\n?/
    },
    'end_nested_expr' => {
      '.rgx' => qr/\G[\ \t]*\)[\ \t]*/
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
            },
            {
              '.ref' => 'modifier_variable'
            },
            {
              '.ref' => 'nested_expr_value'
            }
          ]
        },
        {
          '.ref' => '_'
        }
      ]
    },
    'expression' => {
      '.all' => [
        {
          '.any' => [
            {
              '.ref' => 'assign_expr'
            },
            {
              '.ref' => 'unary_expr'
            },
            {
              '.ref' => 'conditional_statement'
            }
          ]
        },
        {
          '.ref' => 'line_ending'
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
          '.ref' => 'values'
        },
        {
          '.ref' => 'line_ending'
        }
      ]
    },
    'line_ending' => {
      '.rgx' => qr/\G[\ \t]*;[\ \t]*\r?\n?/
    },
    'logic_operator' => {
      '.rgx' => qr/\G([&\|]{2})/
    },
    'math_operator' => {
      '.rgx' => qr/\G([\+\-\*\/%])/
    },
    'modifier_variable' => {
      '.all' => [
        {
          '.ref' => 'identifier'
        },
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'variable'
        }
      ]
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
    'named_block' => {
      '.all' => [
        {
          '.ref' => 'name'
        },
        {
          '.ref' => 'anonymous_block'
        }
      ]
    },
    'nested_expr_value' => {
      '.all' => [
        {
          '.ref' => 'start_nested_expr'
        },
        {
          '.ref' => 'rhs_expr'
        },
        {
          '.ref' => 'end_nested_expr'
        }
      ]
    },
    'number' => {
      '.any' => [
        {
          '.rgx' => qr/\G(0[xX][0-9a-fA-F]+|[0-9]+)/
        },
        {
          '.ref' => 'boolean'
        }
      ]
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
      '+min' => 1,
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
        },
        {
          '.ref' => 'boolean'
        }
      ]
    },
    'single_quoted_string' => {
      '.rgx' => qr/\G(?:'((?:[^\n\\']|\\'|\\\\)*?)')/
    },
    'start_block' => {
      '.rgx' => qr/\G[\ \t]*\{[\ \t]*\r?\n?/
    },
    'start_nested_expr' => {
      '.rgx' => qr/\G[\ \t]*\([\ \t]*/
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
          '.any' => [
            {
              '.ref' => 'name'
            },
            {
              '.ref' => 'variable'
            }
          ]
        },
        {
          '.ref' => 'config_expression'
        },
        {
          '.ref' => 'line_ending'
        }
      ]
    },
    'uc_select' => {
      '.rgx' => qr/\GPIC[\ \t]+((?i:P16F690|P16F690X))[\ \t]*;[\ \t]*\r?\n?/
    },
    'unary_expr' => {
      '.any' => [
        {
          '.ref' => 'unary_lhs'
        },
        {
          '.ref' => 'unary_rhs'
        }
      ]
    },
    'unary_lhs' => {
      '.all' => [
        {
          '.ref' => '_'
        },
        {
          '.ref' => 'unary_operator'
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
    'unary_operator' => {
      '.rgx' => qr/\G(\+\+|\-\-)/
    },
    'unary_rhs' => {
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
          '.ref' => 'unary_operator'
        },
        {
          '.ref' => '_'
        }
      ]
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
              '.ref' => 'named_block'
            },
            {
              '.ref' => 'validated_variable'
            },
            {
              '.ref' => 'modifier_variable'
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
