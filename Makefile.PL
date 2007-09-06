use inc::Module::Install 0.67;

name 'Catalyst-Plugin-SubRequest';
all_from 'lib/Catalyst/Plugin/SubRequest.pm';

requires 'Catalyst::Runtime';

requires 'Test::More';

auto_install;
WriteAll;
