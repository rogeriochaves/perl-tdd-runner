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
	clear_cache("Test.t");
	require("Test.t");
}


sub clear_cache {
	my @files = @_;
	delete $INC{$_} && require $_ for @files;
}

run_tests;

my $watcher = Filesys::Notify::Simple->new([".", "Test.t"]);
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