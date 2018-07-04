#!/usr/contrib/bin/perl
# read intersections.txt and produce HTML version of table

#$| = 1 ;	# turn off output buffering, so we see results if piped, etc
#$[ = 1;		# set array base to 1

$halfgrid = 1 ;	# set to 1 to get diagonal half presentation

$font = 1 ;	# 0 for no special fonts

&PROCESS_ARGS() ;

for ( $halfgrid = 0 ; $halfgrid <= 1 ; $halfgrid++ ) {
	&DOINIT() ;

	&READDATA() ;

	&OUTPUTRESULTS() ;
}

exit 0 ;

sub USAGE {
	print STDERR "usage: perl int2html.pl\n" ;
	exit 1 ;
}

sub PROCESS_ARGS {
	local($arg) ;

	if ( $#ARGV >= 1 ) {
		&USAGE() ;
	}

	while(@ARGV) {
		$arg = shift(@ARGV) ;
	}
}

sub DOINIT {
	$numhdr = 0 ;
	$input = "intersections.txt" ;
	if ( $halfgrid == 1 ) {
		$output = "intersections_half.html" ;
	} else {
		$output = "intersections.html" ;
	}
}

sub READDATA {
	$paper_value = 60 ;
	unless (open(DATAFILE,$input)) {
		printf "Can't open $input: $!\n";
		exit 1 ;
	}
	&READCONTENTS() ;
	close(DATAFILE);
}

sub READCONTENTS {

	$header = 1 ;
	while (<DATAFILE>) {
		chop;       # strip record separator
		@fld = split(' ',$_);

		if ( substr($fld[0],0,1) ne "#" ) {

			if ( $header == 1 ) {
				# if we hit a blank line, done with reading in categories
				if ( $#fld == -1 ) {
					$header = 0 ;
				} else {
					$ltr = substr($fld[0],0,1) ;
					$str = "" ;
					$altstr = "" ;
					$doalt = 0 ;
					for ( $i = 1 ; $i <= $#fld ; $i++ ) {
						if ( $fld[$i] eq '/' ) {
							$doalt = 1 ;
						} else {
							if ( $doalt == 1 ) {
								$altstr .= $fld[$i] . " " ;
							} else {
								$str .= $fld[$i] . " " ;
							}
						}
					}
					if ( $altstr eq "" ) {
						$altstr = $str ;
					}
					chop $altstr ;
					chop $str ;
					$rowhdr[$numhdr] = $str ;
					$colhdr[$numhdr] = $altstr ;
					$ltrhdr[$numhdr] = $ltr ;
					$numhdr++ ;
				}
			} else {
				# in the body
				if ( $#fld >= 0 ) {
					$ltr1 = substr($fld[0],0,1);
					$ltr2 = substr($fld[0],1,1);
					$data = substr($_,4) ;

					# wrap Gems refs with pointer to web site
					# $data =~ s#(Gems.{1,5}?p\.\d+)#<a href="https://github.com/erich666/GraphicsGems/tree/master/">$1</a>#g ;

					# change a href's to aXhref's
					$data =~ s#a href#aXhref#g ;
					#$data =~ s#\*SPACE\*#\%20#g ;

					# change all spaces to non-breaking spaces
					$data =~ s# #&nbsp;#g ;
					
					# change aXhref's to a href's
					$data =~ s#aXhref#a href#g ;

					$grid{$ltr1 . $ltr2} = $data ;
					$grid{$ltr2 . $ltr1} = $data ;
				}
			}
		}
	}
}

sub OUTPUTRESULTS {
	# open file for output
	unless (open(OUTFILE,'>'.$output)) {
		printf "Can't open $output: $!\n";
		exit 1 ;
	}
	# select output file for print operations
	select(OUTFILE) ;
	&OUTPUTLINES();
	close(OUTFILE) ;
}

sub OUTPUTLINES {

#<font size="+3" face="LUCIDA, ARIAL, HELVETICA">
#<h1>3D Object Intersection</h1>
#</font><font face="LUCIDA, ARIAL, HELVETICA">
        print <<"(END HTML HEADER)";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Object/Object Intersection</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
<link rel="icon" href="favicon.ico" type="image/x-icon" />
<link rel="stylesheet" href="rtr3.css" type="text/css" />
</head>
<body bgcolor="#C0DFFD">

<div id="wrapper">

  <div id="header">
    <div id="rtr3-header-image">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr bgcolor="#003F50">
          <td>
            <a href="http://www.realtimerendering.com/blog">
              <img src="rtr-header.png" alt="Header image" width="410" height="106" />
            </a>
          </td>
        </tr>
      </table>
    </div>
    <div id="navigation" class="clearfix">
      <ul class="primary">
        <li><a href="http://www.realtimerendering.com/blog/" rel="home">Blog</a></li>
        <li><a title="Information about the third edition"  href="book.html">Book Information</a></li>
        <li><a title="Recommended books"  href="books.html">Graphics Books</a></li>
        <li><a class="nav-current" title="Object / object intersection page"  href="intersections.html">Intersections</a></li>
        <li><a title="Sites we like"  href="portal.html">Portal</a></li>
        <li><a title="Main resources page"  href="index.html">Resources</a></li>
		<li><a title="WebGL/three.js Resources"  href="webgl.html">WebGL</a></li>
      <ul>
    </div>
  </div>

<div id="content" class="clearfix">

<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td class="pageName">Object/Object Intersection</td>
    </tr>
    <tr>
      <td valign="top"><img src="spacer.gif" alt="" height="6" border="0" /><br />   
    </tr>
    
    <tr>
      <td class="bodyText">

<div class="metadata">
Last changed: June 28, 2017
</div>

<P>





This page gives a grid of intersection routines for various popular objects, pointing to resources
in books and on the web. The most comprehensive books on the subject are
<a href="http://www.geometrictools.com/Books/Books.html"><I>Geometric Tools for Computer Graphics</I></a> (GTCG) and
<a href="http://realtimecollisiondetection.net/"><I>Real-Time Collision Detection</I></a> (RTCD);
the former is all-encompassing, the latter more approachable and focused.
A newer book focused in large part on object/object intersection tests is the
<I><a href="https://gamephysicscookbook.github.io/">Game Physics Cookbook</a></I> (GPC),
with <a href="https://github.com/gszauer/GamePhysicsCookbook">code</a> -
see its <a href="https://github.com/gszauer/GamePhysicsCookbook#collision-detection">giant grid</a> for what intersections it covers.
<P>
Guide to source abbreviations:
<UL>
<LI><B>3DG</B> - <a href="http://www.amazon.com/exec/obidos/ASIN/0201619210?tag=somebooksilike"><I>3D Games: Real-time Rendering and Software Technology</I></a>, Alan Watt and Fabio Policarpo, Addison-Wesley, 2001.

<LI><B>GPC</B> - <I><a href="https://gamephysicscookbook.github.io/">Game Physics Cookbook</a></I>, by Gabor Szauer, Packt Publishing, March 2017, with <a href="https://github.com/gszauer/GamePhysicsCookbook">code</a>

<LI><B>GPG</B> - <a href="http://www.amazon.com/exec/obidos/ASIN/1584500492?tag=somebooksilike"><I>Game Programming Gems</I></a>, ed. Mark DeLoura, Charles River Media, 2000.

<LI><B>GTCG</B> - <a href="http://www.geometrictools.com/Books/Books.html"><I>Geometric Tools for Computer Graphics</I></a>, Philip J. Schneider and David H. Eberly, Morgan Kaufmann Publishers, 2002. Good, comprehensive book on this topic.

<LI><B>Gems</B> - <a href="http://www.graphicsgems.org">The <I>Graphics Gems</I> series</a>. See the book's <a href="http://www.graphicsgems.org">website</a> for individual book links and code.

<LI><B>GTweb</B> - <a href="http://www.geometrictools.com/">Geometric Tools</a>, Dave Eberly's online computer graphics related software repository. His book <a href="http://www.geometrictools.com/Books/Books.html"><I>3D Game Engine Design</I></a> also covers these, in a readable format, as well as many other <a href="http://www.geometrictools.com/Samples/Geometrics.html">object/object intersection tests</a>.

<LI><B>IRT</B> - <a href="http://www.amazon.com/exec/obidos/ASIN/0122861604?tag=somebooksilike"><I>An Introduction to Ray Tracing</I></a>, ed. Andrew Glassner, Academic Press, 1989.

<LI><B>JCGT</B> - <a href="http://jcgt.org/"><I>The Journal of Computer Graphics Techniques</I></a>.

<LI><B>jgt</B> - <a href="http://www.tandfonline.com/toc/ujgt21/current"><I>journal of graphics tools</I></a>. A partial <a href="https://github.com/erich666/jgt-code">code repository</a> is available.

<LI><B>RTCD</B> - <a href="http://realtimecollisiondetection.net/"><I>Real-Time Collision Detection</I></a>, by Christer Ericson, Morgan Kaufmann Publishers, 2004.

<LI><B>RTR</B> - <a href="http://www.realtimerendering.com/"><I>Real-Time Rendering, Third Edition</I></a>, by <a href="http://cs.lth.se/tomas_akenine-moller">Tomas M&ouml;ller</a>, <a href="http://erichaines.com">Eric Haines</a>, and Naty Hoffman, <a href="https://www.crcpress.com/">A.K. Peters Ltd.</a>, 2008.

<LI><B>RTR2</B> - <a href="http://www.realtimerendering.com/"><I>Real-Time Rendering, Second Edition</I></a>, by <a href="http://cs.lth.se/tomas_akenine-moller">Tomas Akenine-M&ouml;ller</a> and <a href="http://erichaines.com">Eric Haines</a>, <a href="https://www.crcpress.com/">A.K. Peters Ltd.</a>, 2002.

<LI><B>SG</B> - <a href="http://plib.sourceforge.net/sg/index.html">Simple Geometry library</a>, Steve Baker's vector, matrix, and quaternion manipulation library.

<LI><B>TGS</B> - <a href="http://www.andrewaye.com/Teikitu%20Gaming%20System/index.html">Teikitu Gaming System Collision</a>, Andrew Aye's object/object intersection/distance and sweep/penetration software (non-commercial use only).

<LI><B>TVCG</B> - <a href="http://www2.computer.org/portal/web/tvcg/">IEEE Transactions on Visualization and Computer Graphics</a>.

</UL>

<P>
Individual article references follow after the table.

<P>
<H2>Static Object Intersections</H2>

Entries are listed from oldest to newest, so often the <i>last</i> entry is the best. This table covers objects not moving; see the next section for dynamic objects.
<P>
<div id="intersect-table">
<table BORDER=1 CELLSPACING=1 CELLPADDING=2 > 
(END HTML HEADER)

	# table header
	printf "<tr>\n  <td>&nbsp;</td>\n" ;
	for ( $i = 0 ; $i < $numhdr ; $i++ ) {
		printf "  <td ALIGN=\"CENTER\"><B>$colhdr[$i]</B><\/td>\n" ;
	}
	printf "  <td>&nbsp;</td>\n</tr>\n";

	# table lines
	for ( $row = 0 ; $row < $numhdr ; $row++ ) {
  		printf "<tr>\n  <td ALIGN=\"LEFT\"><B>$rowhdr[$row]</B><\/td>\n" ;
  		for ( $i = 0 ; $i < $numhdr ; $i++ ) {
			if ( $halfgrid == 1 && $i < $row ) {
				# empty box
   				printf "  <td><\/td>\n" ;
			} else {
 				$str = $grid{$ltrhdr[$row].$ltrhdr[$i]} ;
 				if ( $str eq '' ) {
 					$str = "&nbsp;";
 				}
   				print "  <td ALIGN=\"CENTER\">$str<\/td>\n" ;
			}
  		}
  		printf "  <td ALIGN=\"LEFT\"><B>$rowhdr[$row]</B><\/td>\n" ;
  		printf "<\/tr>\n";
	}
	
	# table header, again
	printf "<tr>\n  <td>&nbsp;</td>\n" ;
	for ( $i = 0 ; $i < $numhdr ; $i++ ) {
		printf "  <td ALIGN=\"CENTER\"><B>$colhdr[$i]</B><\/td>\n" ;
	}
	printf "  <td>&nbsp;</td>\n</tr>\n";

#</font>
    print <<"(END HTML FOOTER)";
</table>
</div>

<P>
References are listed in historical order, so it's usually best to look
at the last reference first. References in parentheses indicate algorithms that will work, but are not optimized
for the particular primitives. Note that all AABB algorithms can also be used
for OBB intersections (simply transform the other primitive to the OBB's
space), so we do not list these in the table.

<H2>Dynamic Object Intersections</H2>

These are intersections in which the objects are moving relative to one another. Linear motion (only) is assumed; there is research on rotational motion collision detection, not covered here. The <a href="http://www.andrewaye.com/Teikitu%20Gaming%20System/index.html">TGS</a> collision system (non-commercial use only) has many methods in this area, and the book <I>Real-Time Collision Detection</I> covers the subject in some depth. 
Other relevant presentations can be found on the <a href="https://www.essentialmath.com/tutorial.htm">Essential Math for Games Programmers</a> site.
One principle is that even if both objects are moving, only one has to be considered moving. That is, one object's movement vector can be subtracted from both objects, leaving one object at rest. Another principle is to perform a <a href="http://www.cs.sunysb.edu/~algorith/files/minkowski-sum.shtml">Minkowski sum</a> (or <a href="http://twvideo01.ubm-us.net/o1/vault/gdc2013/slides/822403Gregorius_Dirk_TheSeparatingAxisTest.pdf">Minkowski difference</a>) of the moving sphere with the other object, essentially shrinking the moving sphere to a ray. A set of static intersection tests are used in many of these tests, so look in the table above for these. The tests below are categorized as <I>boolean</I>, i.e., whether the objects intersect at all, or <I>location</I>, where the actual intersection location where the two moving objects first hit is formed. <I>(Please let me know if you have simple ways of making a given boolean test into a location test.)</I>

<P>
<B>Ray/Moving Sphere:</B> <I>(location)</I> Form a cylinder between the two spheres, intersect the two spheres and cylinder with the ray. See <a href="http://media.steampowered.com/apps/valve/2015/DirkGregorius_Contacts.pdf">Gregorius 2015</a>.<br>
<B>Ray/Moving Triangle:</B> <I>(boolean)</I> If each triangle is entirely on one side of the plane formed by the other triangle, form the polyhedron between the two triangles. The connecting faces are formed by all the combinations of an edge on one triangle and a vertex on the other. Discard any separating planes formed (i.e., use only planes in which both triangles are on the same side of the plane). Shoot the ray against it using <a href="http://www.realtimerendering.com/intersections.html#II247">ray/polyhedron testing</a>. <I>(Short of splitting the triangles into two parts each and forming volumes amongst these, is there an elegant way to perform this operation when one triangle's plane splits the other triangle?)</I><br>
<B>Ray/Moving AABB:</B> <I>(boolean)</I> Form a <a href="http://www.realtimerendering.com/downloads/shaft.zip">shaft</a> (<a href="http://www.erichaines.com/ShaftCulling.pdf">paper</a>) between the beginning and ending position of the AABB and shoot the ray against it using <a href="http://www.realtimerendering.com/intersections.html#II247">ray/polyhedron testing</a>. See RTR3, p. 778 (RTR2, p. 614).<br>
<B>Ray/Moving OBB:</B> <I>(boolean)</I> An inelegant way is to form all combinations of edge/vertex pairs and form planes to bound the OBBs (see Ray/Moving triangle, above).</br>
<B>Ray/Moving Polyhedron:</B> Take the convex hull of each polyhedron and then the convex hull of both of these. <a href="http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=504">Glassner</a> is the earliest reference I know. See <a href="http://media.steampowered.com/apps/valve/2015/DirkGregorius_Contacts.pdf">Gregorius 2015</a> for a modern treatment.

<P>
<B>Plane/Moving Sphere:</B> <I>(location)</I> Transform the problem into changing the plane into a thick slab, of thickness equal to the radius of the sphere. Change the sphere's path into a line segment. Perform slab/line segment intersection, i.e., ray/plane intersection for the two sides of the slab. See <a href="http://www.gamasutra.com/features/19991018/Gomez_1.htm">Gomez</a>; and RTR3, p. 784 (RTR2, p. 621).<br>
<B>Plane/Moving AABB:</B> <I>(location)</I> If the plane's normal is along one of the primary axes, e.g., it is [0 1 0], [0 0 -1], etc., then turn the problem into slab/line segment intersection, similar to plane/moving sphere above. That is, take the thickness of the AABB and make the plane this thick.<br>

<P>
The general principal of intersecting a moving sphere against an object is to simplify thinking about the problem by making the sphere into a line segment between its center's start and end locations, while "adding" this sphere (a <a href="http://www.cs.sunysb.edu/~algorith/files/minkowski-sum.shtml">Minkowski sum</a>) to the other object.<br>
<B>Moving Sphere/Sphere:</B> <I>(location)</I> Add the radius of the moving sphere to the static sphere, and treat the moving sphere as a ray. Use this ray to perform ray/sphere intersection. See <a href="http://www.gamasutra.com/features/19991018/Gomez_1.htm">Gomez</a> and RTR3, p. 785 (RTR2, p. 622).<br>
<B>Moving Sphere/Triangle:</B> <I>(location)</I> Similar to above, turn the sphere into a ray. The triangle turns into a solid defined by a set of spheres at the vertices, cylinders along the edges, and a slab for the interior of the triangle. See <a href="https://github.com/jrouwe/SweptEllipsoid">Rouw&eacute;'s article and code</a>; <a href="https://www.geometrictools.com/Documentation/IntersectionMovingSphereTriangle.pdf">GTWeb doc</a>; RTR3, p. 787 (RTR2 p. 624); <a href="http://twvideo01.ubm-us.net/o1/vault/gdc2013/slides/822403Gregorius_Dirk_TheSeparatingAxisTest.pdf">Gregorius 2012</a>.<br>
<B>Moving Sphere/AABB:</B> <I>(boolean)</I> A conservative test (i.e., no false misses, but can give false hits when there actually is no overlap) is to make the AABB move, so forming a <a href="http://www.realtimerendering.com/downloads/shaft.zip">shaft</a> (<a href="http://www.erichaines.com/ShaftCulling.pdf">paper</a>) between the beginning and ending position of the AABB. Test the static sphere with shaft testing. See RTR3, p. 778 (RTR2, p. 614).<br>

<P>
<B>Moving Triangle/Triangle:</B> See <a href="https://www.geometrictools.com/Documentation/MethodOfSeparatingAxes.pdf">GTweb doc</a> and <a href="https://code.google.com/archive/p/box2d/downloads">Catto 2013</a>.

<P>
<B>Moving AABB/AABB:</B> <I>(location)</I> See <a href="http://www.gamasutra.com/features/19991018/Gomez_3.htm">Gomez</a> for a use of the Separating Axis Theorem to solve this problem. <I>(boolean)</I> Form a <a href="http://www.realtimerendering.com/downloads/shaft.zip">shaft</a> (<a href="http://www.erichaines.com/ShaftCulling.pdf">paper</a>) between the beginning and ending position of the AABB and compare the static AABB against it with shaft testing. See RTR3, p. 778 (RTR2, p. 614).<br>


<P>
<B>Moving OBB/OBB:</B> <I>(location)</I> See <a href="https://www.geometrictools.com/Documentation/IntersectionRotatingBoxes.pdf">GTweb doc</a>.<br>


<P>
<B>Moving Convex Polyhedra/Convex Polyhedra:</B> <I>(boolean)</I> The GTCG book, p. 615 on, gives pseudocode for using the method of separating axes to solve this problem. See <a href="https://www.geometrictools.com/Documentation/MethodOfSeparatingAxes.pdf">GTweb doc</a>.<br>

<P>
<a href="http://media.steampowered.com/apps/valve/2015/DirkGregorius_Contacts.pdf">Gregorius 2015</a> covers computing contact points among spheres, capsules, convex hulls, and meshes.

<P>
Many of the non-curved objects which are moving can be treated as forming <a href="http://www.erichaines.com/ShaftCulling.pdf">shafts</a> between the starting and ending locations, and then the shaft can be tested against a ray simply enough, or against another non-curved object by using the polyhedron/polyhedron test in <a href="#IV83">Gems IV p.83</a>. Another approach is to use the <a href="http://www.geometrictools.com/Documentation/MethodOfSeparatingAxes.pdf">Separating Axis Theorem</a> (also see <a href="http://www.gamasutra.com/features/20000330/bobic_01.htm">Bobic</a>) to tell if the two objects overlap. However, all of these approaches are just <I>boolean</I> tests. Also see RTR3, p. 780 (RTR2, p. 626).

<P>
<H2>Article references</H2>

<B>Bobic</B> - Bobic, Nick, <a href="http://www.gamasutra.com/features/20000330/bobic_01.htm">"Advanced Collision Detection Techniques,"</a> <I>Gamasutra</I>, March 2000.</a>
<BR>
<B>Gomez</B> - Gomez, Miguel, <a href="http://www.gamasutra.com/features/19991018/Gomez_1.htm">"Simple Intersection Tests for Games,"</a> <I>Gamasutra</I>, October 1999.</a>
<BR>
<B>Schroeder</B> - Schroeder, Tim, "Collision Detection Using Ray Casting," <I>Game Developer Magazine</I>, pp. 50-57, August 2001.

<P>
<H2>Graphics Gems references</H2>

<B>Ray/ray:</B> <a name="I304">Ronald Goldman</a>, <I>Intersection of Two Lines in Three-Space</I>, Graphics Gems, p. 304.<br>
<B>Ray/sphere:</B> <a name="I388">Jeff Hultquist</a>, <I>Intersection of a Ray with a Sphere</I>, Graphics Gems, pp. 388-389.<br>
<B>Ray/cylinder:</B> <a name="IV356">Joseph M. Cychosz</a> and Warren N. Waggenspack, Jr., <I>Intersecting a Ray with a Cylinder</I>, Graphics Gems IV, pp. 356-365, <a href="https://github.com/erich666/GraphicsGems/tree/master/gemsiv/ray_cyl.c">includes code</a>.<br>
<B>Ray/polygon:</B> <a name="IV24">Eric Haines</a>, <a href="http://www.erichaines.com/ptinpoly"><I>Point in Polygon Strategies</I></a>, Graphics Gems IV, pp. 24-46, <a href="https://github.com/erich666/GraphicsGems/tree/master/gemsiv/ptpoly_haines">includes code</a>.<br>
<B>Ray/cone:</B> <a name="V227">Ching-Kuang Shene</a>, <I>Computing the Intersection of a Line and a Cone</I>, Graphics Gems V, pp. 227-231.<br>
<B>Ray/AABB:</B> <a name="I395">Andrew Woo</a>, <I>Fast Ray-Box Intersection</I>, Graphics Gems, pp. 395-396, <a href="https://github.com/erich666/GraphicsGems/tree/master/gems/RayBox.c">includes code</a>.<br>
<B>Ray/polyhedron:</B> <a name="II247">Eric Haines</a>, <I>Fast Ray-Convex Polyhedron Intersection</I>, Graphics Gems II, pp. 247-250, <a href="https://github.com/erich666/GraphicsGems/tree/master/gemsii/RayCPhdron.c">includes code</a>.<br>

<P>
<B>Plane/AABB and AABB/polyhedron:</B> <a name="IV74">Ned Greene</a>, <I>Detecting Intersection of a Rectangular Solid and a Convex Polyhedron</I>, Graphics Gems IV, pp. 74-82.<br>

<P>
<B>Sphere/AABB:</B> <a name="I335">Jim Arvo</a>, <I>A Simple Method for Box-Sphere Intersection Testing</I>, Graphics Gems, pp. 247-250, <a href="https://github.com/erich666/GraphicsGems/tree/master/gems/BoxSphere.c">includes code</a>.<br>

<P>
<B>Triangle/AABB:</B> <a name="III236">Doug Voorhies</a>, <I>Triangle-Cube Intersection</I>, Graphics Gems III, pp. 236-239, <a href="https://github.com/erich666/GraphicsGems/tree/master/gemsiii/triangleCube.c">includes code</a>.<br>
<B>Triangle/AABB and AABB/polyhedron:</B> <a name="V375">Green and Hatch</a>, <I>Fast Polygon-Cube Intersection Testing</I>, Graphics Gems V, pp. 375-379, <a href="https://github.com/erich666/GraphicsGems/tree/master/gemsv/ch7-2/">includes code</a>.<br>
<B>Triangle/frustum:</B> <a name="I84">Paul Heckbert</a>, <I>Generic Convex Polygon Scan Conversion and Clipping</I>, Graphics Gems, pp. 84-86, <a href="https://github.com/erich666/GraphicsGems/tree/master/gems/PolyScan/">includes code</a>.<br>

<P>
<B>Polyhedron/polyhedron:</B> <a name="IV83">Rich Rabbitz</a>, <I>Fast Collision Detection of Moving Convex Polyhedra</I>, Graphics Gems IV, pp. 83-109, <a href="https://github.com/erich666/GraphicsGems/tree/master/gemsiv/collide.c">includes code</a>.<br>

<P>
<H2>Algorithms</H2>

Scalar values are lowercase italic: <I>a, n, t</I>. Vectors are lowercase bold: <B>p, v, x</B>. Matrices are uppercase bold: <B>M, T</B>. "X" denotes a cross product, "^2" means "squared", "||<B>x</B>||" means the length of vector <B>x</B>.


<P><font size="+1">
<B>Ray/ray:</B></font> <I>(after Goldman, Graphics Gems; see his article for the derivation)</I> Define each ray by an origin <B>o</B> and a normalized (unit vector) direction <B>d</B>. The two lines are then<P>

<I>L1(t1)</I> = <B>o1</B> + <B>d1</B>*<I>t1</I><BR>
<I>L2(t2)</I> = <B>o2</B> + <B>d2</B>*<I>t2</I><BR>

<P>The solution is:<BR>
<I>t1</I> = Determinant{(<B>o2</B>-<B>o1</B>),<B>d2</B>,<B>d1</B> X <B>d2</B>} / ||<B>d1</B> X <B>d2</B>||^2<P>
and<P>
<I>t2</I> = Determinant{(<B>o2</B>-<B>o1</B>),<B>d1</B>,<B>d1</B> X <B>d2</B>} / ||<B>d1</B> X <B>d2</B>||^2<P>

If the lines are parallel, the denominator ||<B>d1</B> X <B>d2</B>||^2 is 0.<P>
If the lines do not intersect, <I>t1</I> and <I>t2</I> mark the points of closest approach on each line.





 
        </td>
    </tr>
    <tr>
    	<td valign="top"><img src="spacer.gif" alt="" height="1" border="0" /><br />
	&nbsp;<br /></td>
    </tr>
</table>

</div> <!-- /content -->

<div id="footer" class="clearfix">
  <ul>
    <li>Contacts:</li>
    <li><a href="mailto:tam\@cs.lth.se">Tomas</a></li>
    <li><a href="mailto:erich\@acm.org">Eric</a></li>
    <li><a href="mailto:rtr3\@renderwonk.com">Naty</a></li>
  </ul>		
</div> <!-- /footer -->

</div> <!-- /wrapper -->

</body>
</html>
(END HTML FOOTER)
}

sub by_rating { $author_value{$b} <=> $author_value{$a} ; }
sub by_efficiency { $author_efficiency{$b} <=> $author_efficiency{$a} ; }
sub by_value { $tm_value{$b} <=> $tm_value{$a} ; }
sub numerically { $a <=> $b ; }

