#!/usr/contrib/bin/perl
# fix lines in a given file.

# get file, fix it.
# simple filter program: read file(s), process them line by line

my $first_warnings = 1;	# 1 - print warnings of work already done (which might be suspicious)

# show what work is done on this file
my $verbose = 1;

# do you want to check if the header files use "$ifndef _OGS_*" at the top?
my $do_ogs_include = 0;


#  location (from codeFileChecker.pl) of temporary translation perl file for include file capitalization
my $translation_file = "temp_translation.pl";

do $translation_file or printf "Warning: no temp_translation.pl file found, which is rare.\n";

while (@ARGV) {
	# check 
	$arg = shift(@ARGV) ;
	&READ($arg) ;

	$outfile = $arg;
	# for testing: $outfile = "test_out.txt";
	unless (open(OUTFILE,'>'.$outfile)) {
		printf STDERR "Can't open $arg for writing: $!\n";
	}
	
	# final fix: if contents does not end with an end of line, add one.
	if ( substr( $contents, -1 ) ne "\n" ) {
		$contents .= "\n";
	}
	
	print OUTFILE $contents;
	
	close OUTFILE;
}

exit ;

sub READ {
	local($fname) = @_[0] ;

	die "can't open $fname: $!\n"
		unless open(INFILE,$fname) ;
		
	$ifndef_test = 0;
	# do #ifndef test only if wanted and only modify .h files
	if ( $do_ogs_include == 0 || !($fname =~ /\.h$/) ) {
		$ifndef_test = 999;
	}

	while (<INFILE>) {
		#chop;       # strip record separator
		#my @fld = split('/',$_);

		# backslash fix
		$str = $_;
		if ( $str =~ /#include <\w+\\/ || $str =~ /#include "\w+\\/ ||
			 $str =~ /#include "\.\\/ || $str =~ /#include "\..\\/ ) {	# search for backslash
			if ( $verbose ) { printf STDERR "backslash to slash include path fix\n"; }
			$str =~ s/\\/\//g;
		}

		# include -> Include
		if ( $str =~ /#include\s+"include/ ) {
			if ( $verbose ) { printf STDERR "include to Include\n"; }
			$str =~ s/"include/"Include/g;
		}

		# file names are translated to the mixed case names stored in the translation table in temp_translation.pl
		if ( $str =~ /#include/ ) {
			if ( $str =~ /(\w+\.h)"/ ) {
				if ( exists $translate{lc($1)} ) {
					$replace = $translate{lc($1)};
					$str =~ s/$1/$replace/g;
				}
			}
		}
		
		# backslash at end of comment line - add *** commented out ***
		if ( $str =~ /\\\n$/ && $str =~ /\/\// ) {
			if ( $verbose ) { printf STDERR "fix backslash at end of comment line\n"; }
		    chop $str;
			if ( $str =~ /#/ ) {
				# it's a macro definition, so really note there's a blank space at the end.
				if ( $verbose ) { printf STDERR "macro commented out marked as commented\n"; }
				$str .= " *** commented out - to uncomment, remove blank space at end of each line below! ***\n";
			} else {
				$str .= " \n";
			}
		}
		elsif ( $str =~ /\s$/ )
		{
			# get rid of extra spaces at end of line
			$str =~ s/                                $//g;
			$str =~ s/                $//g;
			$str =~ s/        $//g;
		# commented out as it causes a zillion changes to change them all
		#	$str =~ s/    $//g;
		#	$str =~ s/  $//g;
		#	$str =~ s/ $//g;
		}
		
		# translate bad characters to good versions
		if ( $verbose ) {
			if ( $str =~ /(‘|’|“|”|¨|·|–)/ ) {
				printf STDERR "translate bad characters\n";
			}
		}
		#$str =~ tr/[‘,’,“,”,–]/[\',\',\",\",-]/;
		#$str =~ tr/[‘,’,“,”,–]/[',',",",-]/;
		$str =~ tr/[\–,\‘,\’,\“,\”,\¨,\·]/[\-,',',",",",+]/;
		
		# ifndef *_H to OGS_*_H
		if ( $ifndef_test == 0 ) {
			@fld = split(' ',$str);
			if ( $#fld == 1 && $fld[0] eq "#ifndef" ) {
				if ( $fld[1] eq uc($fld[1]) && $fld[1] =~ /(\w|_)+_H/ ) {
					if ( substr($fld[1],0,3) eq "OGS" ) {
						printf "warning: $fname has #ifndef starting with OGS - fixing, but name is now doubled\n";
					}
					if ( substr($fld[1],0,4) ne "_OGS" ) {
						if ( $verbose ) { printf STDERR "fix missing OGS_ prefix for #ifndef\n"; }
						$str = "#ifndef _OGS_" . $fld[1];
						if ( substr($fld[1],-1,1) ne "_" ) {
							$str .= "_";
						}
						$str =~ s/__/_/g;
						$str .= "\n";
						$ifndef_test = 1;
					} else {
						if ( $first_warnings ) {
							printf "warning: $fname already has _OGS\n";
						}
					}
				}
			}
		} elsif ( $ifndef_test == 1 ) {
			# test only the next line after #ifndef
			$ifndef_test = 2;
			@fld = split(' ',$str);
			if ( $#fld == 1 && $fld[0] eq "#define" ) {
				if ( $fld[1] eq uc($fld[1]) && $fld[1] =~ /(\w|_)+_H/ ) {
					if ( substr($fld[1],0,4) ne "_OGS" ) {
						$str = "#define _OGS_" . $fld[1];
						if ( substr($fld[1],-1,1) ne "_" ) {
							$str .= "_";
						}
						$str =~ s/__/_/g;
						$str .= "\n";
					}
				}
			}
		} elsif ( $ifndef_test == 2 ) {
			# test for endif with name
			@fld = split(' ',$str);
			if ( $#fld == 2 && $fld[0] eq "#endif" && $fld[1] eq "//" ) {
				if ( $fld[2] eq uc($fld[2]) && $fld[2] =~ /(\w|_)+_H/ ) {
					if ( substr($fld[2],0,4) ne "_OGS" ) {
						$str = "#endif // _OGS_" . $fld[2];
						if ( substr($fld[2],-1,1) ne "_" ) {
							$str .= "_";
						}
						$str =~ s/__/_/g;
						$str .= "\n";
						$ifndef_test = 3;
					}
				}
			}
		}

		#$contents .= $str . "\n";
		$contents .= $str;
	}
}