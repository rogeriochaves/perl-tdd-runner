use strict;
use warnings;
use Filesys::Notify::Simple;
use File::Basename;
use Test::More;
use Cwd 'cwd';
use Data::Dumper;

# Ignore warnings for subroutines redefined, source: https://www.perlmonks.org/bare/?node_id=539512
$SIG{__WARN__} = sub{
	my $warning = shift;
	warn $warning unless $warning =~ /Subroutine .* redefined at/;
};


sub run_tests {
	my $tb = Test::More->builder;
	$tb->reset();
	delete $INC{"t/Test.t"};
	require("t/Test.t");
}


sub clear_cache {
	my @files = @_;
	for my $file (@files) {
		my $is_test = $file =~ m/\.t$/;
		next if $is_test;

		my $module_key = (grep { $INC{$_} eq $file } (keys %INC))[0];
		next unless $module_key;

		delete $INC{$module_key};
		require $file;
	}
}

run_tests;

my $watcher = Filesys::Notify::Simple->new([".", "t/Test.t"]);
while (1) {
	$watcher->wait(
		sub {
			my @files_changed;
			print "\n";
		  FILE: foreach my $event (@_) {
				my $pwd = cwd();
				my $path = $event->{path};
				$path =~ s/$pwd\///g;

				push @files_changed, $path;
				print $path . " changed\n";
			}
			print "\n";
			print "Running tests...\n";
			clear_cache(@files_changed);
			run_tests;
		}
	);
}