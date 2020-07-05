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
            <li class="breadcrumb-item active">Get full text for papers</li>
        </ol>
        <form action="getFullTextForPapersExecute.cfm" method="post">
            <div class="row">
                
                <div class="col-xl-12">
                    <div class="alert alert-info mt-2">
                        This form accepts a list of paper id's and will return the full text for the papers in an archive file. Use any list separator but the dot ('.').
                        Please note that you can either paste a list of record id's from the table 'paper' (<em>paper.id</em>) OR a list of a list of arxiv id's (<em>paper.arxiv_id</em>). 
                        Processing can take a while, especially if you request full text from multiple papers.
                        Use this list of arxiv id's if you would like to test this form:<br><br>2004.11055<br>1911.08855<br>1904.05168
                    </div>
                    <textarea class="form-control" name="papers" placeholder="Paste a list of paper id's or arxiv ID's here..." rows="10"></textarea>
                </div>
                <div class="col-xl-12">
                    <input type="submit" name="paperarxivid" class="btn btn-info mt-2 float-right" value="Get full text">
                    <div class="form-check mt-2">
                        <label class="form-check-label">
                          <input type="checkbox" class="form-check-input" name="includepdfs" value="1">Include source PDF's in the downloadable archive
                        </label>
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