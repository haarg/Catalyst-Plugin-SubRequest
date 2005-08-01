package Catalyst::Plugin::SubRequest;

use strict;

our $VERSION = '0.07';


=head1 NAME

Catalyst::Plugin::SubRequest - Make subrequests to actions in Catalyst

=head1 SYNOPSIS

    use Catalyst 'SubRequest';

    $c->subreq('/test/foo/bar', { template => 'magic.tt' });

=head1 DESCRIPTION

Make subrequests to actions in Catalyst. Uses the  catalyst
dispatcher, so it will work like an external url call.

=head1 METHODS

=over 4 

=item subreq path, [stash as hash ref], [parameters as hash ref]

=item sub_request

Takes a full path to a path you'd like to dispatch to. Any additional
parameters are put into the stash.

=back 

=cut

*subreq = \&sub_request;

use Data::Dumper qw/Dumper/;
sub sub_request {
    my ( $c, $path, $stash, $params ) = @_;

    my %old_req;
    $path =~ s/^\///;
    local $c->{stash}=$stash || {};
    $old_req{content} = $c->res->output;$c->res->output(undef);
    $old_req{args}    = $c->req->arguments;
    $old_req{action}  = $c->req->action;$c->req->action(undef);
    $old_req{path}    = $c->req->path;$c->req->path($path);
    $old_req{params}  = $c->req->params;$c->req->params($params || {});
    $c->prepare_action();
    $c->log->debug("Subrequest to $path , action is ".  $c->req->action )
        if $c->debug;
    $c->dispatch();
    my $output  = $c->res->output;
    $c->req->{params}=$old_req{params};
    $c->req->arguments($old_req{args});
    $c->req->path($old_req{path});
    $c->res->output($old_req{content});
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
