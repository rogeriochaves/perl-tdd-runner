use strict;
use warnings;
use lib qw(./lib ./example/lib);

use Test::Spec;
use Module::Untested;

describe 'Test::Tdd' => sub {
	it 'finds test folder' => sub {
		my ($test_path, $lib_path) = Test::Tdd::Generator::_find_test_and_lib_folders("example/lib/Module/Untested.pm");
		is($test_path, "example/t");
		is($lib_path, "example/lib");
	};
	it 'generates tests' => sub {
		Module::Untested::foo("baz", 123);

		ok(-e "example/t/Module/Untested.t");

		open FILE, "example/t/Module/Untested.t";
		my $content = join "", <FILE>;
		close FILE;

		ok($content =~ /describe/);
	};
};

runtests;