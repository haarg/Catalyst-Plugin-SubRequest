package Catalyst::Plugin::SubRequest;

use strict;

our $VERSION = '0.04';


=head1 NAME

Catalyst::Plugin::SubRequest - Make subrequests to actions in Catalyst

=head1 SYNOPSIS

    use Catalyst 'SubRequest';

    $c->subreq('/test/foo/bar');

=head1 DESCRIPTION

Make subrequests to actions in Catalyst. Uses the private name of
the action for dispatch.

=head1 METHODS

=over 4 

=item subreq action, args

=item sub_request

Takes a full path to a path you'd like to dispatch to.

=back 

=cut

*subreq = \&sub_request;

sub sub_request {
    my ( $c, $path ) = @_;
    my %old_req;
    $path =~ s/^\///;
    $old_req{stash}   = $c->{stash};$c->{stash}={};
    $old_req{content} = $c->res->output;$c->res->output(undef);
    $old_req{args}    = $c->req->arguments;
    $old_req{action}  = $c->req->action;$c->req->action(undef);
    $old_req{path}  = $c->req->path;$c->req->path($path);
    $c->prepare_action();
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
