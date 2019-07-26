package Test::Tdd::Generator;

use strict;
use warnings;

use File::Basename qw/dirname/;
use File::Path qw/make_path/;


sub create_test {
	my ($package, $filename) = caller();
	my ($test_path, $lib_path) = _find_test_and_lib_folders($filename);
	my $test_file = $filename;
	$test_file =~ s/$lib_path//;
	$test_file =~ s/\.pm$/\.t/;
	$test_file = $test_path . $test_file;

	make_path dirname($test_file);
	open(my $fh, '>', $test_file) or die "Could not open file '$test_file'";
	my $content = <<"END_TXT";
use strict;
use warnings;

use Test::Spec;
use $package;

describe '$package' => sub {
  it 'autogerated test' => sub {

  };
};

runtests;
END_TXT
	print $fh $content;
	close $fh;
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

1;