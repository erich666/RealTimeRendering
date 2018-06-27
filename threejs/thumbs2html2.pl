#!/usr/bin/perl -w

use File::Find;

my $translationFile = "index.html";

my $outputTitle = "Three.js Examples";

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

&HEADER();

my @finddir;
$finddir[0] = ".";
find( \&READRECURSIVEDIR, @finddir, );
&PROCESSFILES(".");
$cfnum = 0;

&FOOTER();

exit 0 ;

sub READRECURSIVEDIR
{
	if ( m/\.(jpg)$/ ) {
	# to check shaders, too: if ( m/\.(cpp|h|cs|cgfx|fx|fxh|ogsfx|ogsfh)$/ ) {
		$codefiles[$cfnum] = $File::Find::name;
		$cfnum++;
	}
}

sub HEADER
{
	open( TRANSLATE, ">" . $translationFile ) or die "Can't open $translationFile: $!\n";
	printf TRANSLATE "%s",<<"EOF";
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html><head><meta content="text/html; charset=ISO-8859-1" http-equiv="content-type"><title>
EOF

		printf TRANSLATE "$outputTitle";
	
		printf TRANSLATE "%s",<<"EOF";
</title>
</head>
<body>
EOF

		printf TRANSLATE "<h1><span style=\"font-family: Lucida Sans;\">$outputTitle</span></h1>\n";
		print TRANSLATE "<div id=\"examples\">\n";
}

sub PROCESSFILES
{
	my $i;
	my @fld;

	#my $addpath = shift(@_);

	#  make include file translation file
	for ( $i = 0 ; $i < $cfnum ; $i++ ) {
		@fld = split('/',$codefiles[$i]);	# split
		$nextfile = $fld[$#fld];

		if ( lc($nextfile) =~ /\.jpg/ ) {
			my $fname = $`;

			print TRANSLATE "<a href=\"http://threejs.org/examples/#$fname\">\n";
			print TRANSLATE "<img src=\"$codefiles[$i]\"></a>\n";
		}
	}
}

sub FOOTER
{
	print TRANSLATE "</div>\n";

	printf TRANSLATE "%s",<<"EOF";
</body></html>
EOF

	close TRANSLATE;
}