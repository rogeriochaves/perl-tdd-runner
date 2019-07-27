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
	my $test_description = shift;

	my ($package, $filename) = caller(0);
	my ($_package, $_filename, $_line, $subroutine) = caller(1);
	my ($test_path, $lib_path) = _find_test_and_lib_folders($filename);

	my $test_file = $filename;
	$test_file =~ s/$lib_path//;
	$test_file =~ s/\.pm$/\.t/;
	$test_file = $test_path . $test_file;

	make_path dirname($test_file);

	my @args = called_args(0);
	my $input = { args => \@args };
	my $input_file = _save_input($test_file, $test_description, $input);

	my $test_body = <<"END_TXT";
    it '$test_description' => sub {
        my \$input = Sereal::Decoder->decode_from_file(dirname(__FILE__) . "/input/$input_file");
        my \$result = $subroutine(\@{\$input->{args}});

        is(\$result, "fixme");
    };
END_TXT

	my $content = <<"END_TXT";
use strict;
use warnings;

use Test::Spec;
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

	print color("green"), "Test created at $test_file:", color("reset"), "\n\n$test_body\n\n";
}


sub _find_test_and_lib_folders {
	my ($path) = @_;

	my $dir = $path;
	while ($dir ne '.') {
		my $base = dirname($dir);
		my $test_folder = "$base/t";
		return ($test_folder, $dir) if -d $test_folder;
		$dir = $base;
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

1;