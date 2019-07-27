use strict;
use warnings;
use lib qw(./lib ./example/lib);

use Test::Spec;
use Module::Untested;
use Module::ImmutableMooseClass;
use Sereal::Decoder;
use File::Spec;

open STDOUT, '>', File::Spec->devnull();

describe 'Test::Tdd::Generator' => sub {
	before each => sub {
		system("rm -rf example/t/Module");
	};

	it 'finds test folder' => sub {
		my ($test_path, $lib_path) = Test::Tdd::Generator::_find_test_and_lib_folders("example/lib/Module/Untested.pm");
		is($test_path, "example/t");
		is($lib_path, "example/lib");
	};

	describe 'test generation' => sub {
		before each => sub {
			my $counter = Module::ImmutableMooseClass->new(counter => 5);
			Module::Untested::untested_subroutine("baz", 123, $counter);
		};

		it 'creates a test file' => sub {
			ok(-e "example/t/Module/Untested.t");
		};

		it 'creates a test in the test file' => sub {
			open FILE, "example/t/Module/Untested.t";
			my $content = join "", <FILE>;
			close FILE;

			ok($content =~ /it 'returns params plus foo'/);
			ok($content =~ /my \$input = Sereal::Decoder->decode_from_file\(dirname\(__FILE__\) . "\/input\/Untested_returns_params_plus_foo\.sereal"\)/);
			ok($content =~ /Module::Untested::untested_subroutine\(@\{\$input->\{args\}\}\)/);
			ok($content =~ /is\(\$result, "fixme"\)/);
		};

		it 'dumps params to a file' => sub {
			my $input = Sereal::Decoder->decode_from_file("example/t/Module/input/Untested_returns_params_plus_foo.sereal");
			is($input->{args}[0], "baz");
			is($input->{args}[1], 123);
			is($input->{args}[2]->counter, 5);
		};

		it 'dies for duplicated test' => sub {
			my $err;
			eval {Module::Untested::untested_subroutine("baz", 123);} or do {
				$err = $@;
			};
			ok($err =~ /Test 'returns params plus foo' already exists on example\/t\/Module\/Untested\.t/);
		};

		it 'appends additional tests' => sub {
			Module::Untested::another_untested_subroutine("ya");

			open FILE, "example/t/Module/Untested.t";
			my $content = join "", <FILE>;
			close FILE;

			ok($content =~ /it 'returns the first param'/);
			ok($content =~ /it 'returns params plus foo'/);
		  }
	};
};

runtests;