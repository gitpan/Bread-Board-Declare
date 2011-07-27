package Bread::Board::Declare::Role::Object;
BEGIN {
  $Bread::Board::Declare::Role::Object::VERSION = '0.10';
}
use Moose::Role;

has name => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub { shift->meta->name },
);

sub BUILD { }
after BUILD => sub {
    my $self = shift;

    my $meta = Class::MOP::class_of($self);

    my %seen = (
        map { $_->class => $_->name }
            grep { $_->isa('Bread::Board::Declare::ConstructorInjection') && Class::MOP::class_of($_->class) }
                 $meta->get_all_services
    );
    for my $service ($meta->get_all_services) {
        if ($service->isa('Bread::Board::Declare::BlockInjection')) {
            my $block = $service->block;
            $self->add_service(
                $service->clone(
                    block => sub {
                        $block->(@_, $self)
                    },
                )
            );
        }
        elsif ($service->isa('Bread::Board::Declare::ConstructorInjection')
            && $service->associated_attribute->infer
            && (my $meta = Class::MOP::class_of($service->class))) {
            my $inferred = Bread::Board::Service::Inferred->new(
                current_container => $self,
                service           => $service->clone,
                infer_params      => 1,
            )->infer_service($service->class, \%seen);

            $self->add_service($inferred);
            $self->add_type_mapping_for($service->class, $inferred);
        }
        else {
            $self->add_service($service->clone);
        }
    }
};

no Moose::Role;


1;

__END__
=pod

=head1 NAME

Bread::Board::Declare::Role::Object

=head1 VERSION

version 0.10

=for Pod::Coverage BUILD

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

