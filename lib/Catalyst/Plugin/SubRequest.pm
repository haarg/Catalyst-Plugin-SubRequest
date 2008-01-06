package Catalyst::Plugin::SubRequest;

use strict;
use Time::HiRes qw/tv_interval/;

our $VERSION = '0.13';

=head1 NAME

Catalyst::Plugin::SubRequest - Make subrequests to actions in Catalyst

=head1 SYNOPSIS

    use Catalyst 'SubRequest';

    $c->subreq('/test/foo/bar', { template => 'magic.tt' });

    $c->subreq(        {       path            => '/test/foo/bar',
                       body            => $body        },
               {       template        => 'magic.tt'           });

=head1 DESCRIPTION

Make subrequests to actions in Catalyst. Uses the  catalyst
dispatcher, so it will work like an external url call.

=head1 METHODS

=over 4 

=item subreq [path as string or hash ref], [stash as hash ref], [parameters as hash ref]

=item sub_request

Takes a full path to a path you'd like to dispatch to.
If the path is passed as a hash ref then it can include body, action, match and path.
Any additional parameters are put into the stash.

=back 

=cut

*subreq = \&sub_request;

sub sub_request {
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
    } else {
        $request_mods{path} = $path;
    }

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
    
    return $inner_ctx->response->body;
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
