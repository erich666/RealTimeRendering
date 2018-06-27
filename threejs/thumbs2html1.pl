#!/usr/bin/perl -w

use File::Find;

my $translation_file = "index.html";

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

my $trans_open_mode = '>';	# open, destroying previous file

my @finddir;
$finddir[0] = ".";
find( \&READRECURSIVEDIR, @finddir, );
&PROCESSFILES(".");
$cfnum = 0;

exit 0 ;

sub READRECURSIVEDIR
{
	if ( m/\.(jpg)$/ ) {
	# to check shaders, too: if ( m/\.(cpp|h|cs|cgfx|fx|fxh|ogsfx|ogsfh)$/ ) {
		$codefiles[$cfnum] = $File::Find::name;
		$cfnum++;
	}
}

sub PROCESSFILES
{
	my $i;
	my @fld;

	#my $addpath = shift(@_);

	#  make include file translation file
	open( TRANSLATE, $trans_open_mode . $translation_file ) or die "Can't open $translation_file: $!\n";
	$trans_open_mode = '>>';	# append from now on in
	for ( $i = 0 ; $i < $cfnum ; $i++ ) {
		@fld = split('/',$codefiles[$i]);	# split
		$nextfile = $fld[$#fld];

		if ( lc($nextfile) =~ /\.jpg/ ) {
			my $fname = $`;
			print TRANSLATE "<a href=\"http://threejs.org/examples/#$fname\">\n";
			print TRANSLATE "<img src=\"$codefiles[$i]\"></a>\n";
		}
	}
	close TRANSLATE;
}
