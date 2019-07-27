package Test::Tdd::Generator;

use strict;
use warnings;

use File::Basename qw/dirname basename/;
use File::Path qw/make_path/;
use Devel::Caller::Perl qw/called_args/;
use Sereal qw(encode_sereal);
use Sereal::Encoder;


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
	_save_input($test_file, $test_description, $input);

	die "Test '$test_description' already exists on $test_file" if _test_exists($test_file, $test_description);

	open(my $fh, '>', $test_file) or die "Could not open file '$test_file'";
	my $content = <<"END_TXT";
use strict;
use warnings;

use Test::Spec;
use $package;
use File::Basename qw/dirname/;
use Sereal::Decoder;

describe '$package' => sub {
  it '$test_description' => sub {
    my \$input = Sereal::Decoder->decode_from_file(dirname(__FILE__) . "/input/Untested_returns_params_plus_foo.sereal");
    my \$result = $subroutine(\@{\$input->{args}});

    is(\$result, "fixme");
  };
};

runtests;
END_TXT
	print $fh $content;
	close $fh;

	print "Test created: $test_file\n";
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
	Sereal::Encoder->encode_to_file("$inputs_folder/$test_file_base\_$test_description.sereal", $input);
}


sub _test_exists {
	my ($test_file, $test_description) = @_;
	if (-e $test_file) {
		open FILE, $test_file;
		my $content = join "", <FILE>;
		close FILE;
		return $content =~ /it '$test_description'/;
	}
	return;
}

1;