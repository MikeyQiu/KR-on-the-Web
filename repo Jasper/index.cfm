<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="">
  <meta name="author" content="">

  <title></title>

	<!-- Bootstrap core CSS -->
	<link href="vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
	<link href="css/dscs.css" rel="stylesheet">
	<link href="css/bootstrap-slider.min.css" rel="stylesheet">
	<link href="css/jquery.json-viewer.css" rel="stylesheet">
    <link rel="stylesheet" href="css/modal-video.min.css">
    <script src="https://kit.fontawesome.com/c80dff83b6.js" crossorigin="anonymous"></script>
    <link href="https://unpkg.com/gijgo@1.9.13/css/gijgo.min.css" rel="stylesheet" type="text/css" />    
    <link rel="stylesheet" href="css/spinner.css">
</head>
<body>

    <!-- Page Content -->
    <div class="container mb-5 mt-2" id="page">
        <h3>Knowledge Representation on the Web</h3>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">Home</li>
        </ol>

        <hr>
        <h5>Get full text for papers</h5>
        <p>Get full text for papers.</p>
        <a href="getFullTextForPapers.cfm"      class="btn btn-info btn-sm">Get full text</a>

        <hr>

        <h5>MAKG - Find authors by paper</h5>
        <p>Match authors to authors in the Microsoft Academic Knowledge Graph.</p>
        <a href="makgFindAuthorsByPaper.cfm"    class="btn btn-info btn-sm">Run a query</a>

        <hr>

        <h5>Find the ORCID for a person</h5>
        <p>Search for author ORCID ID's by name in the ORCID Public API. Just a little demonstration for now. Not tied into the database yet.</p>
        <a href="orcid.cfm" class="btn btn-info btn-sm">Search for an author</a>

        <hr>

        <h5>Batch - Match papers to the MAKG</h5>
        <p>Try to match our papers to the Microsoft Academic Knowledge Base so we can do owl:sameAs things with them.</p>
        <a href="matchPapersToMAKG.cfm" class="btn btn-info btn-sm">Go</a>

        <div class="row">
            <div class="col-xl-6">
            </div>
        </div>

        <hr>

        <h5>Find ORCIDs for all authors</h5>
        <p>---</p>
        <a href="findORCIDForAllAuthors.cfm" class="btn btn-info btn-sm">Go</a>

        <div class="row">
            <div class="col-xl-6">
            </div>
        </div>

    </div>

        <!-- Bootstrap core JavaScript -->
        <script src="//www.scoaring.com/dscs/vendor/jquery/jquery.min.js" type="text/javascript"></script>
        <script src="js/index.js" type="text/javascript"></script>
        <script src="vendor/bootstrap/js/bootstrap.bundle.min.js" type="text/javascript"></script>
        <!-- <script src="js/bootstrap-slider-master/src/js/bootstrap-slider.js"></script> -->
        <script src="js/dateFormat.js" type="text/javascript"></script>
        <script src="js/jquery-dateformat.min.js" type="text/javascript"></script>
        <script src="js/jquery-modal-video.min.js" type="text/javascript"></script>
        <script src="js/gijgo.min.js" type="text/javascript"></script>
    </body>
</html>