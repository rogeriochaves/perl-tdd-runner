package Module::Untested;

use strict;
use warnings;
use Test::Tdd::Generator;

$Global::VARIABLE = 'foo';


sub untested_subroutine {
	my @params = @_;

	Test::Tdd::Generator::create_test('returns params plus foo');

	return join(',', @params) . $Global::VARIABLE;
}

1;