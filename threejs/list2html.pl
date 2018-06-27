#!/usr/contrib/bin/perl
# fix lines in a given file.
#
# perl list2html.pl new_ones.txt > new.html

# get file of names of programs and make HTML for index.html file

while (@ARGV) {
	# check 
	$arg = shift(@ARGV) ;
	&READ($arg) ;
}

exit ;

sub READ {
	local($fname) = @_[0] ;

	die "can't open $fname: $!\n"
		unless open(INFILE,$fname) ;

	while (<INFILE>) {
		chop;       # strip record separator

		@fld = split('_',$_);
		if ( $fld[0] ne $prev ) {
			$prev = $fld[0];
			$prefix = $fld[0];
			if ( $prev eq "webgldeferred" ) {
				printf "\n<h1>webgl deferred</h1>\n";
			} else {
				printf "\n<h1>$prev</h1>\n";
			}
		}
		elsif ( $advanced == 0 && $fld[1] eq "buffergeometry" ) {
			$advanced = 1;
			$prev = "webgl";
			$prefix = "webgl_advanced";
			printf "\n<h1>webgl / advanced</h1>\n";
		}
		$str = $title = $_;
		$title =~ s/_/ \/ /g;
		printf "<a href=\"http://threejs.org/examples/\#$str\">\n";
		printf "<img src=\"./$prefix/$str.jpg\" title=\"$title\" alt=\"$title\" height=\"100\" width=\"150\" /></a>\n";
	}
}