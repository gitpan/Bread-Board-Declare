package Bread::Board::Declare::Meta::Role::Attribute;
BEGIN {
  $Bread::Board::Declare::Meta::Role::Attribute::VERSION = '0.01';
}
use Moose::Role;
Moose::Util::meta_attribute_alias('Service');
# ABSTRACT: attribute metarole for Bread::Board::Declare

use Bread::Board::Types;
use List::MoreUtils qw(any);

use Bread::Board::Declare::BlockInjection;
use Bread::Board::Declare::ConstructorInjection;
use Bread::Board::Declare::Literal;



has service => (
    is      => 'ro',
    isa     => 'Bool',
    default => 1,
);


has block => (
    is        => 'ro',
    isa       => 'CodeRef',
    predicate => 'has_block',
);


# has_value is already a method
has literal_value => (
    is        => 'ro',
    isa       => 'Str|CodeRef',
    init_arg  => 'value',
    predicate => 'has_literal_value',
);


has lifecycle => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_lifecycle',
);


has dependencies => (
    is        => 'ro',
    isa       => 'Bread::Board::Service::Dependencies',
    coerce    => 1,
    predicate => 'has_dependencies',
);


has constructor_name => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_constructor_name',
);


has associated_service => (
    is        => 'rw',
    does      => 'Bread::Board::Service',
    predicate => 'has_associated_service',
);

after attach_to_class => sub {
    my $self = shift;

    return unless $self->service;

    my %params = (
        associated_attribute => $self,
        name                 => $self->name,
        ($self->has_lifecycle
            ? (lifecycle => $self->lifecycle)
            : ()),
        ($self->has_dependencies
            ? (dependencies => $self->dependencies)
            : ()),
        ($self->has_constructor_name
            ? (constructor_name => $self->constructor_name)
            : ()),
    );

    my $service;
    if ($self->has_block) {
        $service = Bread::Board::Declare::BlockInjection->new(
            %params,
            block => $self->block,
        );
    }
    elsif ($self->has_literal_value) {
        $service = Bread::Board::Declare::Literal->new(
            %params,
            value => $self->literal_value,
        );
    }
    elsif ($self->has_type_constraint) {
        my $tc = $self->type_constraint;
        if ($tc->isa('Moose::Meta::TypeConstraint::Class')) {
            $service = Bread::Board::Declare::ConstructorInjection->new(
                %params,
                class => $tc->class,
            );
        }
    }

    $self->associated_service($service) if $service;
};

after _process_options => sub {
    my $class = shift;
    my ($name, $opts) = @_;

    return unless exists $opts->{default}
               || exists $opts->{builder};
    return unless exists $opts->{class}
               || exists $opts->{block}
               || exists $opts->{value};

    # XXX: uggggh
    return if any { $_ eq 'Moose::Meta::Attribute::Native::Trait::String'
                 || $_ eq 'Moose::Meta::Attribute::Native::Trait::Counter' }
              @{ $opts->{traits} };

    my $exists = exists($opts->{default}) ? 'default' : 'builder';
    die "$exists is not valid when Bread::Board service options are set";
};

around get_value => sub {
    my $orig = shift;
    my $self = shift;
    my ($instance) = @_;

    return $self->$orig($instance)
        if $self->has_value($instance);

    my $val = $instance->get_service($self->name)->get;

    $self->verify_against_type_constraint($val, instance => $instance)
        if $self->has_type_constraint;

    if ($self->should_auto_deref) {
        if (ref($val) eq 'ARRAY') {
            return wantarray ? @$val : $val;
        }
        elsif (ref($val) eq 'HASH') {
            return wantarray ? %$val : $val;
        }
        else {
            die "Can't auto_deref $val.";
        }
    }
    else {
        return $val;
    }
};

if (Moose->VERSION > 1.9900) {
    around _inline_instance_get => sub {
        my $orig = shift;
        my $self = shift;
        my ($instance) = @_;
        return 'do {' . "\n"
                . 'my $val;' . "\n"
                . 'if (' . $self->_inline_instance_has($instance) . ') {' . "\n"
                    . '$val = ' . $self->$orig($instance) . ';' . "\n"
                . '}' . "\n"
                . 'else {' . "\n"
                    . '$val = ' . $instance . '->get_service(\'' . $self->name . '\')->get;' . "\n"
                    . $self->_inline_check_constraint(
                        '$val', '$type_constraint', '$type_constraint_obj'
                    )
                . '}' . "\n"
                . '$val' . "\n"
            . '}';
    };
}
else {
    around accessor_metaclass => sub {
        my $orig = shift;
        my $self = shift;

        return Moose::Meta::Class->create_anon_class(
            superclasses => [ $self->$orig(@_) ],
            roles        => [ 'Bread::Board::Declare::Meta::Role::Accessor' ],
            cache        => 1
        )->name;
    };
}

no Moose::Role;

1;

__END__
=pod

=head1 NAME

Bread::Board::Declare::Meta::Role::Attribute - attribute metarole for Bread::Board::Declare

=head1 VERSION

version 0.01

=head1 DESCRIPTION

This role adds functionality to the attribute metaclass for
L<Bread::Board::Declare> objects.

=head1 ATTRIBUTES

=head2 service

Whether or not to create a service for this attribute. Defaults to true.

=head2 block

The block to use when creating a L<Bread::Board::BlockInjection> service.

=head2 literal_value

The value to use when creating a L<Bread::Board::Literal> service. Note that
the parameter that should be passed to C<has> is C<value>.

=head2 lifecycle

The lifecycle to use when creating the service. See L<Bread::Board::Service>
and L<Bread::Board::LifeCycle>.

=head2 dependencies

The dependency specification to use when creating the service. See
L<Bread::Board::Service::WithDependencies>.

=head2 constructor_name

The constructor name to use when creating L<Bread::Board::ConstructorInjection>
services. Defaults to C<new>.

=head2 associated_service

The service object that is associated with this attribute.

=head1 SEE ALSO

=over 4

=item *

L<Bread::Board::Declare>

=back

=head1 AUTHOR

Jesse Luehrs <doy at tozt dot net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Jesse Luehrs.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
