#!/usr/bin/perl -w

# Perl script that looks for bad code usage.
# See https://share.autodesk.com/sites/Airmax/airviz/AIRViz%20Wiki/Wiki%20Pages/Coding%20Portability%20Guidelines.aspx for why these changes are made.
#
# You need to install cygwin on your machine, or provide some similar "expand" DOS command to turn tabs into spaces.
# This perl program runs under ActiveState's free Perl distribution.
#
# You will need to edit some of the lines below, such as directory paths for where OGS code is located, etc.
#
# Run from the AIRViz/Devel directory (not sure this is required...), by:
#
# c:\PlatformSDK\GEC_OGS\AIRViz\Devel>perl "c:\PlatformSDK\GEC_OGS\AIRViz\Tools\CodeFileChecker\codeFileChecker.pl" > check_files.bat
#
# Then look over the .bat file, change what needs changing, and run the .bat file. You have to run
# from a \Devel directory, though, to get the right paths - the script isn't that fancy (yet).
#
# It creates check_files.bat, which you then can check over and then run from the command line.
#
# NOTE: you will probably have to search and replace "PlatformSDK/GEC_OGS" with "PlatformSDK/branches/GEC_OGS".
#
# Running the batch file will check out all the files that need fixing. Files with tabs will get fixed
# automatically, you have to fix the rest by hand.
# It is up to you to then check the set of files into Perforce.

# header - YOU MUST CHANGE AS NEEDED, and set your  password if needed as shown with commented-out line:
print "rem set P4PORT=psebp4w:1444\n";
print "rem set P4CLIENT=Eric_Haines_OGS\n";
print "rem set P4USER=hainese\n";
print "rem set P4PASSWD=??????\n";
print "set P4PORT=psebp4:1444\n";
print "set P4CLIENT=haines_GEC_OGS\n";
print "set P4USER=hainese\n";

# this is where the addHeader.pl script lives (same as where codeFileChecker.pl lives)
my $toolpath = "c:\\PlatformSDK\\GEC_OGS\\AIRViz\\Tools\\CodeFileChecker\\";

# these are the places to check on down the directory structure
my @dirs = ( "\\PlatformSDK\\GEC_OGS\\AIRViz\\Devel\\", "\\PlatformSDK\\GEC_OGS\\AIRViz\\SDK\\Include\\" );
#my @dirs = ( "C:\\temp\\BadCharacters");

# this is what prefix to add to Perforce paths
my @perforcepath = ( "//depot", "//depot" );

# this is the patch where "expand" lives. YMMV. Cygwin is at https://www.cygwin.com/install.html
my $expandpath = "c:\\cygwin64\\bin\\";

# Set this to 1 to check if any lines in a file are longer than 100 characters.
# In theory every file lives up to this standard, in practice few do.
$dolonglines = 0;

# Set this to 1 to look for backslashes at the end of comment lines. Mac gcc doesn't like these.
$dobackslashcommentcheck = 1;

# Set this to 1 to look for lines with extra spaces at end - trim those away.
# This thing will trim nearly every file in OGS; I ran it once, it worked, but was a bit horrifying
# so I didn't do the check-in. Turned it off...
$dospacesatendoflinecheck = 0;

# Set this to 1 to dump out doxygen problems at the end. These should be fixed by hand.
# NOTE: don't try to run file when this is set to true, just read the file produced for errors.
# Also, there will be false positives, e.g. where comments are put into the doc lines, etc.
$showDoxygen = 0;

# where to put temporary translation perl file for include file capitalization
my $translation_file = "temp_translation.pl";


# do you want to check if the header files use "$ifndef _OGS_*" at the top?
my $do_ogs_include = 0;

use File::Find;

my $pragma='';
my $ifndef='';
my $ogs_include='';
my $copyright='';
my $codefix1='';
my $codefix2='';
my $codefix3='';
my $codefix4='';
my $codefix5='';
my $tabs2spaces='';
my $dupfiles='';
my $longline='';
my $badcharfix='';

$cfnum = 0;

#@dirs = @ARGV or $dirs[0] = '.';	# default is current directory
my $dirchop = 0 ;
if ( $dirs[0] eq '.' ) {
	$dirchop = 2 ;
}

my $trans_open_mode = '>';	# open, destroying previous file
my $dirnum;
for ( $dirnum = 0; $dirnum <= $#dirs; $dirnum++ ) {
    my @finddir;
	$finddir[0] = $dirs[$dirnum];
	print STDERR "Processing $finddir[0]";
	find( \&READRECURSIVEDIR, @finddir, );
	&PROCESSFILES($perforcepath[$dirnum]);
	undef @codefiles;
	$cfnum = 0;
	print STDERR "\n";
}

exit 0 ;

sub READRECURSIVEDIR
{
	if ( m/\.(cpp|h|cs)$/ ) {
	# to check shaders, too: if ( m/\.(cpp|h|cs|cgfx|fx|fxh|ogsfx|ogsfh)$/ ) {
		$codefiles[$cfnum] = $File::Find::name;
		$cfnum++;
	}
}

sub PROCESSFILES
{
	my $i;
	my @fld;

	$addpath = shift(@_);

	#  make include file translation file
	open( TRANSLATE, $trans_open_mode . $translation_file ) or die "Can't open $translation_file: $!\n";
	$trans_open_mode = '>>';	# append from now on in
	for ( $i = 0 ; $i < $cfnum ; $i++ ) {
		@fld = split('/',$codefiles[$i]);	# split
		$nextfile = $fld[$#fld];

		# generate translation file for include file name translation
		if ( !($codefiles[$i] =~ /kcg/) && $nextfile =~ /\.h/ &&
			# this next test is for checking that the filename has mixed case. However, there are some files where
			# the correct name is lowercase but the include directive uses mixed case. So, removed: all names are now translated.
			# ($nextfile ne lc($nextfile) ) &&
			 lc($nextfile) ne "stdafx.h" ) {
			# check if name is in table.
			my $lcout = lc($nextfile);
			if ( exists $translate{$lcout} ) {
				# already in table - do they match?
				if ( $translate{$lcout} ne $nextfile ) {
					print STDERR "ERROR! File name $nextfile is also present as $translate{$lcout}. Fix filenames or this script.\n";
				}
			}
			else {
				$translate{$lcout} = $nextfile;
				print TRANSLATE "\$translate{'$lcout'} = '$nextfile';\n", ;
			}
		}
	}
	close TRANSLATE;
	print STDERR "\n  made translation file\n";

	# do $translation_file;

	for ( $i = 0 ; $i < $cfnum ; $i++ ) {
	    if ( $i % 50 == 0 ) {
			print STDERR ".";
		}
		@fld = split('/',$codefiles[$i]);	# split
		$nextfile = $fld[$#fld];
		my @subfld;
		@subfld = split('\.',$nextfile);
		#$filecore = $subfld[0];
		#$path = substr($codefiles[$i],$dirchop,length($codefiles[$i])-length($nextfile)-$dirchop);
#printf "PATH: $path vs $codefiles[$i]\n";
		#printf "file is $nextfile\n";

		$input = $codefiles[$i];
		# HERE'S WHERE TO ADD DIRECTORIES TO IGNORE - NOTE: must add the paths as lowercase
		# ignore resource files and kcg library files and a number of directories with auto-generated files, etc.
		if ( !($input =~ "\/resource.h") && 
			 !(lc($input) =~ "\/kcg\/") && 
			 !(lc($input) =~ "\/fxparser\/") && 
			 !(lc($input) =~ "\/gles20\/") && 	# eventually will be deleted
			 !(lc($input) =~ "\/optimizer\/") && 
			 !(lc($input) =~ "\/fragdebug\/") && 
			 !(lc($input) =~ "\/glslgenerator.cpp") && # this file is crazy enough that it shouldn't be analyzed
			 !(lc($input) =~ "\/shaderheaders\/") && 
			 !(lc($input) =~ "\/generatedfiles\/") ) {
			#$input =~ s/\\\//\//g;	# \/ to / 
			&READCODEFILE();
		}
	}

	if ( length($ogs_include) > 0 ) {
		print "rem\nrem\nrem CHANGE #ifndef _FILENAME_H_ to #ifndef _OGS_FILENAME_H_\nrem\nrem\n";
		print $ogs_include;
		$ogs_include='';
	}
	if ( length($copyright) > 0 ) {
		print "rem\nrem\nrem ADD COPYRIGHT NOTICE AT TOP OF FILE\nrem\nrem\n";
		print $copyright;
		$copyright='';
	}
	if ( length($tabs2spaces) > 0 ) {
		print "rem\nrem\nrem CHANGE TABS TO SPACES (done automatically, just check in code)\nrem\nrem\n";
		print $tabs2spaces;
		$tabs2spaces='';
	}
	if ( length($codefix1) > 0 ) {
		print "rem\nrem\nrem REPLACE BACKSLASHES WITH FORWARD SLASHES\nrem\nrem\n";
		print $codefix1;
		$codefix1='';
	}
	if ( length($codefix2) > 0 ) {
		print "rem\nrem\nrem ALL \"include -> \"Include\nrem\nrem\n";
		print $codefix2;
		$codefix2='';
	}
	if ( length($codefix3) > 0 ) {
		print "rem\nrem\nrem ALL include lowercase to MixedCase\nrem\nrem\n";
		print $codefix3;
		$codefix3='';
	}
	if ( length($codefix4) > 0 ) {
		print "rem\nrem\nrem Append *** to any commented lines with continuation \\ characters at EOL.\nrem\nrem\n";
		print $codefix4;
		$codefix4='';
	}
	if ( length($eofeolfix) > 0 ) {
		print "rem\nrem\nrem FILE DOES NOT END WITH AN EOL CHARACTER\nrem\nrem\n";
		print $eofeolfix;
		$eofeolfix='';
	}
	if ( length($badcharfix) > 0 ) {
		print "rem\nrem\nrem FILE HAD BAD CHARACTERS IN IT\nrem\nrem\n";
		print $badcharfix;
		$badcharfix='';
	}
	if ( length($dupfiles) > 0 ) {
		print STDERR "\n" . $dupfiles;
		$dupfiles='';
	}
	if ( length($longline) > 0 ) {
		print $longline;
		$longline='';
	}
	if ( length($ifndef) > 0 ) {
		print "rem\nrem\nrem #ifndef _include once_ wrapper code missing from these files - please fix by hand!\nrem\nrem\n";
		print $ifndef;
		$ifndef='';
	}
	#if ( length($pragma) > 0 ) {
	#	print "rem\nrem\nrem CHANGE #pragma once TO #ifndef _FILENAME_H_ - you must do this by hand!\nrem\nrem\n";
	#	print $pragma;
	#	$pragma='';
	#}
	if ( $showDoxygen && length($codefix5) > 0 ) {
		print "rem\nrem\nrem Fix doxygen problems.\nrem\nrem\n";
		print $codefix5;
		$codefix5='';
	}
	print STDERR "Processed $cfnum files.\n";
}

sub READCODEFILE
{
	# slurp the whole file by locally setting $/ to nothing.
	local( $/, *FH ) ;
	open( FH, $input ) or die "Can't open $input: $!\n";

	# whole file read in - yeah, it's overkill
	$content = <FH>;
	if ( $input =~ /\\\// ) {
		$suffixinput = '/' . $';
		$input = $` . '/' . $'; 	# \/ to / 
		$modinput = $addpath . substr($suffixinput,1);
	} else {
		$modinput = $addpath . $input;
	}

	# backslashes to forward slashes
	$modinput =~ s/\\/\//g;
	$input =~ s/\//\\/g;
	# hack
	$modinput =~ s/PlatformSDK/PlatformSDK\/branches/;
	#$modinput =~ s/\//\\/g;
	#printf STDERR "addpath is $addpath, input is $input\n";

	# check if file name is used more than once in this area of the code
	if ( !(lc($nextfile) =~ "stdafx.h") && 
		 !(lc($nextfile) =~ "stdafx.cpp") &&
		 !(lc($nextfile) =~ "targetver.h") &&
		 !(lc($nextfile) =~ "assemblyinfo.cpp") &&
		 !(lc($nextfile) =~ "module.h") &&
		 !(lc($nextfile) =~ "module.cpp") &&
		 !($input =~ "RapidRT/LightSet.cpp") &&		# ignore RapidRT/LightSet.cpp for now. Asked Carina Rydell to rename.
		 !($input =~ "RapidRTShaders") &&		# ignore RapidRTShaders files, as these .cpp files are generated by .rtsl's
		 !($input =~ "GL") ) {		# ignore GL files, as they match GLCoreProfile files
		if ( exists($filesused{lc($nextfile)}) ) {
			$dupfiles .= "File name $nextfile is used twice:\n";
			$dupfiles .= "    $filesused{lc($nextfile)}\n";
			$dupfiles .= "    $input\n";
		} else {
			$filesused{lc($nextfile)} = $input;
		}
	}
    
	if ( $content =~ /\t/ ) {	# search for tab
		# if any tab found, see if line(s) found have "" quotes around them (some shader code)
		$line_count = 1;
		# check for lines with tabs, then look for quote marks
		$post_line = $content;
		$quit = 0;
		while ( $post_line =~ /\n/ && !$quit) {
			$post_line = $';
			$the_line = $`;
		    if ( $the_line =~ /\t/ ) {
				# found a bad line with a tab
				my $pre = $`;
				my $post = $';
				if ( $pre =~ /\"/ && $post =~ /\"/ )
				{
					$quit = 1;
				}
			}
			$line_count++;
		}
		# tabs all found on lines without "" around them.
		if ( !$quit ) {
			$tabs2spaces .= "p4 edit \"$modinput\"\n";
			$tabs2spaces .= sprintf "\"%sexpand\" --tabs=4 \"$input\" > junktest\n", $expandpath;
			$tabs2spaces .= sprintf "move junktest \"$input\"\n";
		}
	}

	if ( !(lc($content) =~ / copyright/) ) {	# search for copyright - put space in front to catch quoted "copyright
		$copyright .= "p4 edit \"$modinput\"\n";
		$copyright .= sprintf "perl \"%saddHeader.pl\" \"$input\"\n", $toolpath;
	}

	#if ( $content =~ /#pragma\s+once/ && !($modinput =~ /aglMacro_macos/) ) {	# search for pragma once, but allow OGL fix
	#	$pragma .= "p4 edit \"$modinput\"\n";
	#}

	if ( $input =~ /\.h/ && !($input =~ /CharsetInfo.h/) && !($content =~ /#ifndef/) && !($content =~ /#define/) 
		&& !($content =~ /#pragma\s+once/)) {	# search for ifndef/define in .h file, which must be there
		# $ifndef .= "echo Missing a #pragma once or an #ifndef \"$modinput\"\n";
		$ifndef .= "echo Missing a #pragma once or an #ifndef \"$input\"\n";
	}

	#include file fixes

	# check for "#ifndef *_H"
	if ( $do_ogs_include && $content =~ /#ifndef (\w|_)+_H/ && $content =~ /#define (\w|_)+_H/ ) {
		if ( !($& =~ /_OGS_/) && !($& =~ /_STDAFX_H/) ) {
			$ogs_include .= "rem ifndef fix $&\n";
			$ogs_include .= "p4 edit \"$modinput\"\n";
			$ogs_include .= sprintf "perl \"%scodeFixer.pl\" \"$input\"\n", $toolpath;
		}
	}
	
	# check for "include "include\somefile.h" backslash.
	if ( $content =~ /#include <\w+\\/ || $content =~ /#include "\w+\\/ ||
			$content =~ /#include "\.\\/ || $content =~ /#include "\..\\/ ) {	# search for backslash
		$codefix1 .= "rem backslash fix\n";
		$codefix1 .= "p4 edit \"$modinput\"\n";
		$codefix1 .= sprintf "perl \"%scodeFixer.pl\" \"$input\"\n", $toolpath;
	}

	# check for '#include "include"', should be '#include "Include"'
	if ( $content =~ /#include\s+"include/ && !($content =~ /L"include/) && !($modinput =~ OGSTextLayoutManagerForLine) ) {
		$codefix2 .= "rem '#include \"include\"' being changed to '#include \"Include\"'\n";
		$codefix2 .= "p4 edit \"$modinput\"\n";
		$codefix2 .= sprintf "perl \"%scodeFixer.pl\" \"$input\"\n", $toolpath;
	}

	# check for include file with lowercase name. Need to iterate through file's contents
	$post_line = $content;
	$quit = 0;
	while ( $post_line =~ /#include/ && !$quit) {
		$post_line = $';
		if ( $post_line =~ /\n/ ) {
			$rest_of_line = $`;
#print "here's $nextfile include $rest_of_line\n";
			$post_line = $';
		} else {
			$rest_of_line = '';
		}

		if ( $rest_of_line =~ /(\w+\.h)"/ ) {
			if ( exists $translate{lc($1)} && $1 ne $translate{lc($1)} ) {
				$codefix3 .= "rem lowercase to mixed case because of $rest_of_line\n";
				$codefix3 .= "rem $1 ne $translate{lc($1)}\n";
				$codefix3 .= "p4 edit \"$modinput\"\n";
				$codefix3 .= sprintf "perl \"%scodeFixer.pl\" \"$input\"\n", $toolpath;
				$quit = 1;
			}
		}
	}
	
	# check for last character not being an end of line
	if ( substr( $content, -1 ) ne "\n" ) {
		$eofeolfix .= "p4 edit \"$modinput\"\n";
		$eofeolfix .= sprintf "perl \"%scodeFixer.pl\" \"$input\"\n", $toolpath;
	}
	
	# check for illegal characters like ’
	# Bad characters
	#if ( $input ~= /(‘|’|“|”|–)/ ) {
	if ( $content =~ /(‘|’|“|”|¨|·|–)/ ) {
		$badcharfix .= "p4 edit \"$modinput\"\n";
		$badcharfix .= sprintf "perl \"%scodeFixer.pl\" \"$input\"\n", $toolpath;
	}
	
	if ( $dobackslashcommentcheck ) {
		$line_count = 1;
		# check for lines ending in \, then look for comments
		$post_line = $content;
		$quit = 0;
		while ( $post_line =~ /\n/ && !$quit) {
			$post_line = $';
			$the_line = $`;
		    if ( $the_line =~ /\\$/ && $the_line =~ /\/\// ) {
				# found a bad line with a comment and \ at very end
				$codefix4 .= "rem backslash found at end of commented-out line\n";
				$codefix4 .= "p4 edit \"$modinput\"\n";
				$codefix4 .= sprintf "perl \"%scodeFixer.pl\" \"$input\"\n", $toolpath;
				$quit = 1;
			}
			$line_count++;
		}
	}
	
	if ( $dospacesatendoflinecheck ) {
		$line_count = 1;
		# check for lines ending in spaces, then check if line is comment and has a \
		$post_line = $content;
		$quit = 0;
		while ( $post_line =~ /\n/ && !$quit) {
			$post_line = $';
			$the_line = $`;
			# check that line has extra spaces and is not a comment line with a "\ " at end, which is the only OK reason to have a space at the end of a line
		    if ( $the_line =~ / $/ && !($the_line =~ /\\ $/ && $the_line =~ /\/\//) ) {
				# found a bad line with a comment and \ at very end
				$codefix4 .= "rem found spaces at the end of the line\n";
				$codefix4 .= "p4 edit \"$modinput\"\n";
				$codefix4 .= sprintf "perl \"%scodeFixer.pl\" \"$input\"\n", $toolpath;
				$quit = 1;
			}
			$line_count++;
		}
	}
	
	if ( $dolonglines ) {
		$line_count = 1;
		# check for lines with more than 100 characters
		$post_line = $content;
		$quit = 0;
		while ( $post_line =~ /\n/ && !$quit) {
			$post_line = $';
			# printf "line is $` for $modinput\n";
			if ( length($`) > 100 ) {
				#$longline .= "rem file \"$modinput\" line $line_count longer than 100 characters.\n";
				$longline .= "$modinput: line $line_count longer than 100 characters.\n";
				$quit = 1;
			}
			$line_count++;
		}
	}
	
	if ( $showDoxygen ) {
		&FINDDOXYGENPROBLEM('description');
		&FINDDOXYGENPROBLEM('param');
		&FINDDOXYGENPROBLEM('remarks');
		&FINDDOXYGENPROBLEM('returns');
		&FINDDOXYGENPROBLEM('return');
	}

	close FH;
}

sub FINDDOXYGENPROBLEM
{
    my ($tagword) = @_;

	# check for include file with lowercase name. Need to iterate through file's contents
	$input =~ s/\//\\/g;
	$post_line = $content;
	$quit = 0;
	while ( $post_line =~ /\/ <$tagword/ && !$quit) {
		$post_line = $';
		if ( $post_line =~ /<\/$tagword/ ) {
			$rest_of_line = $`;
#print "here's $nextfile include $rest_of_line\n";
			$post_line = $';
		} else {
			$rest_of_line = '';
			$codefix5 .= "rem MISSING </$tagword in \"$input\"\n";
			$codefix5 .= "   Look for: $rest_of_line\n";
			$quit = 1;
		}

		if ( $rest_of_line =~ / \/\/ / ) {
			$codefix5 .= "rem look for two-slashes in \"$input\"\n";
			$codefix5 .= "   Look for: $rest_of_line\n";
			$quit = 1;
		}
		if ( $rest_of_line =~ /<$tagword/ ) {
			$codefix5 .= "rem DOUBLED </$tagword> in \"$input\"\n";
			$codefix5 .= "   Look for: $rest_of_line\n";
			$quit = 1;
		}
	}
}
