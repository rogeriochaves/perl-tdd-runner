package Test::Tdd::Generator;

use strict;
use warnings;

use File::Basename qw/dirname basename/;
use File::Path qw/make_path/;
use Devel::Caller::Perl qw/called_args/;
use Sereal qw(encode_sereal);
use Sereal::Encoder;
use Term::ANSIColor;


sub create_test {
	my ($test_description, $opts) = @_;

	my ($package, $filename) = caller(0);
	my ($_package, $_filename, $_line, $subroutine) = caller(1);
	my ($test_path, $lib_path) = _find_test_and_lib_folders($filename);

	my $actual_test_path;
	if (not -w $test_path) {
		$actual_test_path = $test_path;
		$test_path = "/tmp/t";
	}

	my $test_file = $filename;
	$test_file =~ s/$lib_path//;
	$test_file =~ s/\.pm$/\.t/;
	$test_file = $test_path . $test_file;

	make_path dirname($test_file);

	my @args = called_args(0);
	my $globals = {};
	$globals = _get_globals($opts->{globals}) if defined $opts->{globals};
	my $input = { args => \@args, globals => $globals };
	my $input_file = _save_input($test_file, $test_description, $input);

	my $global_expansion = "";
	$global_expansion = "\n        Test::Tdd::Generator::expand_globals(\$input->{globals});\n" if defined $opts->{globals};
	my $test_body = <<"END_TXT";
    it '$test_description' => sub {
        my \$input = Sereal::Decoder->decode_from_file(dirname(__FILE__) . "/input/$input_file");$global_expansion
        my \$result = $subroutine(\@{\$input->{args}});

        is(\$result, "fixme");
    };
END_TXT

	my $content = <<"END_TXT";
use strict;
use warnings;

use Test::Spec;
use Test::Tdd::Generator;
use $package;
use File::Basename qw/dirname/;
use Sereal::Decoder;

describe '$package' => sub {
$test_body
};

runtests;
END_TXT

	if (-e $test_file) {
		die "Test 'returns params plus foo' already exists on $test_file" if _test_exists($test_file, $test_description);
		open FILE, "example/t/Module/Untested.t";
		$content = join "", <FILE>;
		close FILE;
		$content =~ s/(\};\n\nruntests)/$test_body$1/;
	}

	open(my $fh, '>', $test_file) or die "Could not open file '$test_file'";
	print $fh $content;
	close $fh;

	print _get_instructions($test_file, $test_body, $test_path, $actual_test_path);
}


sub _get_instructions {
	my ($test_file, $test_body, $test_path, $actual_test_path) = @_;

	my $run_instructions = color("green") . "Run it with:" . color("reset") . "\n\n    provetdd $test_file\n\n";
	my $move_instructions = "";
	if ($actual_test_path) {
		my $path_to_copy = dirname($actual_test_path);
		$move_instructions = color("green") . "To copy it to the correct place run:" . color("reset") . "\n\n    cp -R /tmp/t $path_to_copy\n\n";
		$run_instructions =~ s/$test_path/$actual_test_path/;
	}

	return color("green") . "Test created at $test_file:" . color("reset") . "\n\n$test_body\n" . $move_instructions . $run_instructions;
}


sub _find_test_and_lib_folders {
	my ($path) = @_;

	my $dir = dirname($path);
	my $previous = $dir;
	while ($dir ne '.') {
		my $test_folder = "$dir/t";
		return ($test_folder, $previous) if -d $test_folder;
		$previous = $dir;
		$dir = dirname($dir);
	}
	die "Could not find t/ folder put the tests, searched in $path";
}


sub _save_input {
	my ($test_file, $test_description, $input) = @_;

	my $inputs_folder = dirname($test_file) . '/input';
	make_path $inputs_folder;
	$test_description =~ s/ /_/g;
	my $test_file_base = basename($test_file, ".t");
	my $input_file = "$test_file_base\_$test_description.sereal";
	Sereal::Encoder->encode_to_file("$inputs_folder/$input_file", $input);

	return $input_file;
}


sub _test_exists {
	my ($test_file, $test_description) = @_;

	open FILE, $test_file;
	my $content = join "", <FILE>;
	close FILE;

	return $content =~ /it '$test_description'/;
}


sub _get_globals {
	my ($globals_names) = @_;

	return { map { $_ => _get_global_var($_) } @$globals_names };
}


sub _get_global_var {
	my $name = shift;

	my $global_var = eval "\$$name";
	if ($global_var) {
		return $global_var;
	} else {
		my %global_map = eval "\%$name";
		%global_map = map { ($_ => _get_global_var($name . $_) ) } (keys %global_map);
		return \%global_map;
	}
}


sub expand_globals {
	my ($globals, $parent) = @_;
	$parent ||= '';

	for my $key (keys %{$globals}) {
		my $value = $globals->{$key};
		if ($key =~ /::$/) {
			expand_globals($value, $parent . $key);
		} else {
			eval("\$$parent$key = \$value");
		}
	}
}

1;