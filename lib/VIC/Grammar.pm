package VIC::Grammar;
use strict;
use warnings;

use base 'Pegex::Grammar';
# use XXX;

use constant file => './share/vic.pgx';

sub make_tree {
  {
    '+grammar' => 'vic',
    '+toprule' => 'program',
    '+version' => '0.0.1',
    'DOLLAR' => {
      '.rgx' => qr/\G\$/
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
          '.ref' => 'name'
        },
        {
          '.rgx' => qr/\G[\ \t]*\{[\ \t]*\r?\n?/
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
    'double_quoted_string' => {
      '.rgx' => qr/\G(?:"((?:[^\n\\"]|\\"|\\\\|\\[0nt])*?)")/
    },
    'end_block' => {
      '.rgx' => qr/\G[\ \t]*\}[\ \t]*\r?\n?/
    },
    'header' => {
      '.any' => [
        {
          '.ref' => 'uc_header'
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
        }
      ]
    },
    'single_quoted_string' => {
      '.rgx' => qr/\G(?:'((?:[^\n\\']|\\'|\\\\)*?)')/
    },
    'statement' => {
      '.any' => [
        {
          '.ref' => 'comment'
        },
        {
          '.ref' => 'block'
        },
        {
          '.ref' => 'instruction'
        },
        {
          '.ref' => 'end_block'
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
    'uc_header' => {
      '.rgx' => qr/\Gset_(config|org)[\ \t]*(.*);\r?\n/
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
