package Bread::Board::Declare::ConstructorInjection;
BEGIN {
  $Bread::Board::Declare::ConstructorInjection::VERSION = '0.10';
}
use Moose;
# ABSTRACT: subclass of Bread::Board::ConstructorInjection for Bread::Board::Declare


extends 'Bread::Board::ConstructorInjection';
with 'Bread::Board::Declare::Role::Service';

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__
=pod

=head1 NAME

Bread::Board::Declare::ConstructorInjection - subclass of Bread::Board::ConstructorInjection for Bread::Board::Declare

=head1 VERSION

version 0.10

=head1 DESCRIPTION

This is a custom subclass of L<Bread::Board::ConstructorInjection> which does
the L<Bread::Board::Declare::Role::Service> role. See those two modules for
more details.

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

