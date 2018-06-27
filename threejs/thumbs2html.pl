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
<span style=\"font-family: Lucida Sans;\">
EOF

		printf TRANSLATE "<h1>$outputTitle</h1>\n";
		print TRANSLATE "Thumbnails for <a href=\"http://threejs.org/examples/\">three.js examples</a>\n";
		print TRANSLATE "<div id=\"examples\">\n";
}

sub PROCESSFILES
{
	my $i;
	my @fld;

	#my $addpath = shift(@_);

	#  make include file translation file
	my @dirnames = ("webgl", "webgl_advanced", "webvr", "css3d", "css3d_stereo", "misc", "canvas", "raytracing", "software", "svg");
	foreach my $n (@dirnames) {
		my $write_dir = 1;
		for ( $i = 0 ; $i < $cfnum ; $i++ ) {
			@fld = split('/',$codefiles[$i]);	# split
			$nextfile = $fld[$#fld];

			if ( $codefiles[$i] =~ ($n . "/") && lc($nextfile) =~ /\.jpg/ ) {
				my $fname = $`;

				if ( $write_dir ) {
					$write_dir = 0;
					my $dir_field = $fld[$#fld-1];
					$dir_field =~ tr/_/ /;
					print TRANSLATE "<h1>$dir_field</h1>\n";
				}
				
				my $alt_text = $fname;
				$alt_text =~ s/_/ \/ /g;

				print TRANSLATE "<a href=\"http://threejs.org/examples/#$fname\">\n";
				print TRANSLATE "<img src=\"$codefiles[$i]\" title=\"$alt_text\" alt=\"$alt_text\" height=\"100\" width=\"150\" /></a>\n";
			}
		}
	}
}

sub FOOTER
{
	print TRANSLATE "</div>\n";

	printf TRANSLATE "%s",<<"EOF";
<hr>
<a href="threejs_thumbs.zip">Download this site</a>. Something wrong or missing? Contact <a href="mailto:erich\@acm.org">Eric Haines</a>.
<P>
Go to the <b><a href="http://www.realtimerendering.com/webgl.html">WebGL/three.js resources page</a></b>.
<P>
<I>Last updated April 20, 2016</I>
</span>
</body></html>
EOF

	close TRANSLATE;
}