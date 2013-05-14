package Bread::Board::Declare::Meta::Role::Instance;
BEGIN {
  $Bread::Board::Declare::Meta::Role::Instance::AUTHORITY = 'cpan:DOY';
}
{
  $Bread::Board::Declare::Meta::Role::Instance::VERSION = '0.14';
}
use Moose::Role;

# XXX: ugh, this should be settable at the attr level, fix this in moose
sub inline_get_is_lvalue { 0 }

no Moose::Role;


1;

__END__

=pod

=head1 NAME

Bread::Board::Declare::Meta::Role::Instance

=head1 VERSION

version 0.14

=for Pod::Coverage inline_get_is_lvalue

=head1 AUTHOR

Jesse Luehrs <doy at tozt dot net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jesse Luehrs.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
