package Bread::Board::Declare::Meta::Role::Class;
BEGIN {
  $Bread::Board::Declare::Meta::Role::Class::VERSION = '0.02';
}
use Moose::Role;
# ABSTRACT: class metarole for Bread::Board::Declare

use Bread::Board::Service;
use List::MoreUtils qw(any);



sub get_all_services {
    my $self = shift;
    return map { $_->associated_service }
           grep { $_->has_associated_service }
           grep { Moose::Util::does_role($_, 'Bread::Board::Declare::Meta::Role::Attribute') }
           $self->get_all_attributes;
}

before superclasses => sub {
    my $self = shift;

    return unless @_;

    die "Multiple inheritance is not supported for Bread::Board::Declare classes"
        if @_ > 1;

    return if $_[0]->isa('Bread::Board::Container');

    die "Cannot inherit from " . join(', ', @_)
      . " because Bread::Board::Declare classes must inherit"
      . " from Bread::Board::Container";
};

no Moose::Role;

1;

__END__
=pod

=head1 NAME

Bread::Board::Declare::Meta::Role::Class - class metarole for Bread::Board::Declare

=head1 VERSION

version 0.02

=head1 DESCRIPTION

This role adds functionality to the metaclass of L<Bread::Board::Declare>
classes.

=head1 METHODS

=head2 get_all_services

Returns all of the services that are associated with attributes in this class.

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

