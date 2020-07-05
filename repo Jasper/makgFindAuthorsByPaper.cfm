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
        <h3>MAKG - Find authors by paper</h3>
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="index.cfm">Home</a></li>
            <li class="breadcrumb-item active">MAKG - Find authors by paper</li>
        </ol>

        <form action="makgFindAuthorsByPaperExecute.cfm" method="post">
            <div class="row">
                <div class="col-xl-12">
                    <p>Match authors to authors in the Microsoft Academic Knowledge Graph. We might be able to use this script to match our authors to authors in the MAKG using the sameAs construct.</p>
                    <p>Paste a list of titles for papers (each on a new line) and submit the form. For each title the script will (SPARQL) query the MAKG SPARQL end point for the authors that contributed to the paper title being queried. BTW It looks like newer papers are not listed.</p>
                    <textarea class="form-control" name="papers" placeholder="Paste a list of paper id's or arxiv ID's here..." rows="10">
Competitive and Penalized Clustering Auto-encoder
Semantic Compositionality through Recursive Matrix-Vector Spaces
A non-DNN Feature Engineering Approach to Dependency Parsing -- FBAML at CoNLL 2017 Shared Task                        
                    </textarea>
                    <input type="submit" name="paperarxivid" class="btn btn-info mt-2 float-right" value="Query the MAKG">
                </div>
            </div>
        </form>

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