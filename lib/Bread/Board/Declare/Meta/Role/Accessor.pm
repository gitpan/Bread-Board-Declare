package Bread::Board::Declare::Meta::Role::Accessor;
BEGIN {
  $Bread::Board::Declare::Meta::Role::Accessor::VERSION = '0.06';
}
use Moose::Role;

around _inline_get => sub {
    my $orig = shift;
    my $self = shift;
    my ($instance) = @_;

    my $attr = $self->associated_attribute;

    return 'do {' . "\n"
             . 'my $val;' . "\n"
             . 'if (' . $self->_inline_has($instance) . ') {' . "\n"
                 . '$val = ' . $self->$orig($instance) . ';' . "\n"
             . '}' . "\n"
             . 'else {' . "\n"
                 . '$val = ' . $instance . '->get_service(\'' . $attr->name . '\')->get;' . "\n"
                 . $self->_inline_check_constraint('$val')
             . '}' . "\n"
             . '$val' . "\n"
         . '}';
};

no Moose::Role;

1;

__END__
=pod

=head1 NAME

Bread::Board::Declare::Meta::Role::Accessor

=head1 VERSION

version 0.06

=head1 SEE ALSO

Please see those modules/websites for more information related to this module.

=over 4

=item *

L<Bread::Board::Declare|Bread::Board::Declare>

=back

=head1 AUTHOR

Jesse Luehrs <doy at tozt dot net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Jesse Luehrs.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

