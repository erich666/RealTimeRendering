/* globals
   Blazy
   chapter_list
   figure_files
*/

// Call initialize() after the page has loaded.
$( initialize );

// Initializes the image gallery.
function initialize()
{
    // Constants.
    var figure_dir = 'figures/';
    var thumb_dir  = 'figures/thumb/';
    var thumb_ext  = 'jpg';

    // The list of figures, grouped into chapters, with each chapter having an array of figure data.
    var figures = {};

    // Define a regex with three capture groups: chapter (two digits), figure ID (two digits), and
    // file extension, e.g. RTR4.06.38.left.png produces [06, 38, png].
    var regex = /RTR4\.(\d{2})\.(\d{2})(?:\.\S*)?\.(\S*)/;

    // Iterate the figure image file array.
    figure_files.forEach( function( element )
    {
        // Match the capture groups in the regex with the image file name. Return if the file name
        // does not match the pattern.
        var matches = regex.exec( element );
        if( !matches )
        {
            return;
        }

        // Get the chapter and figure ID as integers. Return if they are not integers.
        var chapter = parseInt( matches[1], 10 );
        var id      = parseInt( matches[2], 10 );
        if( isNaN( chapter ) || isNaN( id ) )
        {
            return;
        }

        // Create a chapter entry in the figures object if it doesn't already exist.
        if( !figures.hasOwnProperty( chapter ) )
        {
            figures[chapter] = [];
        }

        // Add the figure data to the array of figure data for the chapter.
        figures[chapter].push({
            file : element,
            id   : id,
            ext  : matches[3],
        });
    });

    // Iterate the chapter entries in the figures object, and sort each figure data array by ID.
    $.each( figures, function( _key, value )
    {
        value.sort( function( first, second )
        {
            return first.id - second.id;
        });
    });

    // Get the gallery element, which will be populated with the table of contents and images.
    var $gallery = $( '#gallery' );

    // Iterate the chapter entries in the figures objects, building a table of contents with
    // internal links.
    $.each( figures, function( key )
    {
        var chapter_title = 'Chapter ' + key + ': ' + chapter_list[key];
        var $link         = $( '<a href="#ch' + key + '">' ).text( chapter_title );
        $gallery.append( $( '<li>' ).append( $link ) );
    });

    // Iterate the chapter entries in the figures objects, adding thumbnails for each figure.
    // NOTE: Since the chapter keys are numbers, they will be iterated in ascending order by
    // default, so sorting is not needed.
    $.each( figures, function( key, value )
    {
        // Create an add a chapter heading, with a ID to support the table of contents.
        var chapter_title = 'Chapter ' + key + ': ' + chapter_list[key];
        $( '<h1 id="ch' + key + '">' ).text( chapter_title ).appendTo( $gallery );

        // Iterate the array of figure data for the chapter, adding thumbnails for each figure.
        value.forEach( function( element )
        {
            // Build the (relative) paths to the figure and its thumbnail.
            var figure_path = figure_dir + element.file;
            var thumb_path  = thumb_dir + element.file.slice( 0, -element.ext.length ) + thumb_ext;

            // Specify the tooltip text.
            var tooltip = 'Figure ' + key + '-' + element.id;

            // Create an image object, prepared for lazy loading with bLazy: use a special class,
            // and specify the actual thumbnail image in a data attribute.
            var $image = $( '<img>' )
                .addClass( 'b-lazy' )
                .attr( 'data-src', thumb_path )
                .attr( 'title', tooltip );

            // Add the image to the gallery, wrapped inside a thumbnail container.
            var $container = $( '<div>' ).addClass( 'thumbnail' );
            var $center    = $( '<span>' ).addClass( 'img_center' );
            $gallery.append( $container.append( $center ).append( $image ) );

            // Add a click handler to the container that will simply open a new window (tab) with
            // the full-size image.
            $container.click( function()
            {
                window.open( figure_path, '_blank' );
            });
        });
    });

    // Create a bLazy object, which will find the "b-lazy" images and perform lazy loading, i.e.
    // swap out the loading images with the thumbnail images when they are visible. This is much
    // better than hammering the server with 400+ requests, and is good for clients with slower or
    // metered connections. See http://dinbror.dk/blog/blazy.
    var _blazy = new Blazy();
}
