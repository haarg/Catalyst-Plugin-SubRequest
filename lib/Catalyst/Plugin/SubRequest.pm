package Catalyst::Plugin::SubRequest;

use strict;
use warnings;
use Time::HiRes qw/tv_interval/;

our $VERSION = '0.17';

=head1 NAME

Catalyst::Plugin::SubRequest - Make subrequests to actions in Catalyst

=head1 SYNOPSIS

    use Catalyst 'SubRequest';

    my $res_body = $c->subreq('/test/foo/bar', { template => 'magic.tt' });

    my $res_body = $c->subreq( {
       path            => '/test/foo/bar',
       body            => $body
    }, {
       template        => 'magic.tt'
    });

    # Get the full response object
    my $res = $c->subreq_res('/test/foo/bar', {
        template => 'mailz.tt'
    }, {
        param1   => 23
    });
    $c->log->warn( $res->content_type );

=head1 DESCRIPTION

Make subrequests to actions in Catalyst. Uses the  catalyst
dispatcher, so it will work like an external url call.
Methods are provided both to get the body of the response and the full
response (L<Catalyst::Response>) object.

=head1 METHODS

=over 4

=item subreq [path as string or hash ref], [stash as hash ref], [parameters as hash ref]

=item subrequest

=item sub_request

Takes a full path to a path you'd like to dispatch to.

If the path is passed as a hash ref then it can include body, action,
match and path.

An optional second argument as hashref can contain data to put into the
stash of the subrequest.

An optional third argument as hashref can contain data to pass as
parameters to the subrequest.

Returns the body of the response.

=item subreq_res [path as string or hash ref], [stash as hash ref], [parameters as hash ref]

=item subrequest_response

=item sub_request_response

Like C<sub_request()>, but returns a full L<Catalyst::Response> object.

=back

=cut

*subreq = \&sub_request;
*subrequest = \&sub_request;
*subreq_res = \&sub_request_response;
*subrequest_response = \&sub_request_response;

sub sub_request {
    return shift->sub_request_response( @_ )->body ;
}

sub sub_request_response {
    my ( $c, $path, $stash, $params ) = @_;

    $path =~ s#^/##;

    $params ||= {};

    my %request_mods = (
        body => undef,
        action => undef,
        match => undef,
        parameters => $params,
    );

    if (ref $path eq 'HASH') {
        @request_mods{keys %$path} = values %$path;
        $path = $path->{path};
    } else {
        $request_mods{path} = $path;
    }
    $request_mods{_body} = delete $request_mods{body};

    my $fake_engine = bless(
        {
            orig_request => $c->req,
            request_mods => \%request_mods,
        },
        'Catalyst::Plugin::SubRequest::Internal::FakeEngine'
    );

    my $class = ref($c);

    no strict 'refs';
    no warnings 'redefine';

    local *{"${class}::engine"} = sub { $fake_engine };

    my $inner_ctx = $class->prepare;

    $inner_ctx->stash($stash || {});


    $c->stats->profile(
        begin   => 'subrequest: /' . $path,
        comment => '',
    ) if ($c->debug);

    $inner_ctx->dispatch;

    $c->stats->profile( end => 'subrequest: /' . $path ) if ($c->debug);

    return $inner_ctx->response;
}

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHORS

Marcus Ramberg, C<mramberg@cpan.org>

Tomas Doran (t0m) C<< bobtfish@bobtfish.net >>

=head1 THANK YOU

SRI, for writing the awesome Catalyst framework

=head1 COPYRIGHT

Copyright (c) 2005 - 2011
the Catalyst::Plugin::SubRequest L</AUTHORS>
as listed above.

=head1 LICENSE

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

package # hide from PAUSE
  Catalyst::Plugin::SubRequest::Internal::FakeEngine;

sub AUTOLOAD { return 1; } # yeah yeah yeah

sub prepare {
    my ($self, $c) = @_;
    my $req = $c->request;

    @{$req}{keys %{$self->{orig_request}}} = values %{$self->{orig_request}};
    while (my ($key,$value) = each %{$self->{request_mods}}) {
        if (my $mut = $req->can($key)) {
            $req->$mut($value);
        } else {
            $req->{$key} = $value;
        }
    }
}

1;
