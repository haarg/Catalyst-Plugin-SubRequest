package Catalyst::Plugin::SubRequest;

use strict;

our $VERSION = '0.04';


=head1 NAME

Catalyst::Plugin::SubRequest - Make subrequests to actions in Catalyst

=head1 SYNOPSIS

    use Catalyst 'SubRequest';

    $c->subreq('!test','foo','bar');

=head1 DESCRIPTION

Make subrequests to actions in Catalyst.

=head1 METHODS

=over 4 

=item subreq action, args

=item sub_request

takes the name of the action you would like to call, as well as the
arguments you want to pass to it.

=back 

=cut

*subreq = \&sub_request;

sub sub_request {
    my ( $c, $action, @args ) = @_;
    my %old_req;
    $old_req{stash}   = $c->{stash};$c->{stash}={};
    $old_req{content} = $c->res->output;$c->res->output(undef);
    $old_req{args}    = $c->req->arguments;$c->req->arguments([@args]);
    $old_req{action}  = $c->req->action;$c->req->action($action);
    $c->dispatch();
    my $output  = $c->res->output;
    $c->{stash} = $old_req{stash};
    $c->res->output($old_req{content});
    $c->req->arguments($old_req{args});
    $c->req->action($old_req{action});
    return $output;
}

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHOR

Marcus Ramberg, C<mramberg@cpan.org>

=head1 THANK YOU

SRI, for writing the awesome Catalyst framework

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
