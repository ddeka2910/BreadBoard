package Bread::Board::Dumper;
our $AUTHORITY = 'cpan:STEVAN';
# ABSTRACT: Pretty printer for visualizing the layout of your Bread::Board
$Bread::Board::Dumper::VERSION = '0.34';
use Moose;

sub dump {
    my ($self, $thing, $indent) = @_;

    $indent = defined $indent ? $indent . '  ' : '';

    my $output = '';

    if ($thing->isa('Bread::Board::Dependency')) {
        $output .= join('', $indent, "depends_on: ", $thing->service_path || $thing->service->name, "\n");
    }
    elsif ($thing->does('Bread::Board::Service')) {
        $output .= join('', $indent, "service: ", $thing->name, "\n" );

        if ($thing->does('Bread::Board::Service::WithDependencies')) {
            while (my($key, $value) = each %{ $thing->dependencies }) {
                $output .= $self->dump($value, $indent);
            }
        }
    }
    elsif ($thing->isa('Bread::Board::Container')) {
        $output = join('', $indent, "container: ", $thing->name, "\n" );

        my ($key, $value);

        while (($key, $value) = each %{ $thing->sub_containers }) {
            $output .= $self->dump($value, $indent);
        }

        while (($key, $value) = each %{ $thing->services }) {
            $output .= $self->dump($value, $indent);
        }
    }

    return $output;
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::Dumper - Pretty printer for visualizing the layout of your Bread::Board

=head1 VERSION

version 0.34

=head1 SYNOPSIS

  use Bread::Board::Dumper;

  print Bread::Board::Dumper->new->dump($container);

  # container: Application
  #   container: Controller
  #   container: View
  #     service: TT
  #       depends_on: include_path
  #   container: Model
  #     service: dsn
  #     service: schema
  #       depends_on: pass
  #       depends_on: ../dsn
  #       depends_on: user

=head1 DESCRIPTION

This is a useful utility for dumping a clean view of a Bread::Board
container.

=head1 AUTHOR (actual)

Daisuke Maki

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/stevan/BreadBoard/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
