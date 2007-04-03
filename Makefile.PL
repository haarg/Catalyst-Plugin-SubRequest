use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Catalyst::Plugin::SubRequest',
    AUTHOR    => 'Marcus Ramberg <marcus@thefeed.no>',
    PREREQ_PM => {
        Catalyst     => '5.00',
    },
    VERSION_FROM => 'SubRequest.pm'
);
