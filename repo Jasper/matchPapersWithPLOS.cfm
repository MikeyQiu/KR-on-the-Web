<!--- --->
<cfsetting RequestTimeout = "0">

<!--- --->
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
    
<!--- --->
<cfquery name="qPaper" datasource="#sDSN#" maxrows=1000>
    SELECT  paper.title
    ,       paper.paper_url
    FROM    paper
    WHERE   paper.title <> ''
</cfquery>

<!-- Page Content -->
<cfoutput>
<div class="container mb-5 mt-2" id="page">
    <!--- --->
    <cfloop query="qPaper">
        <cftry>

            <!--- --->
            <cfset sCleanTitle = qPaper.title>
            <cfset sCleanTitle = replaceNoCase(sCleanTitle, ":", "", "All")>
            <cfset sCleanTitle = replaceNoCase(sCleanTitle, "/", "", "All")>
            <cfset sCleanTitle = replaceNoCase(sCleanTitle, "\", "", "All")>
            <cfset sCleanTitle = replaceNoCase(sCleanTitle, "|", "", "All")>
            <cfset sCleanTitle = replaceNoCase(sCleanTitle, "[", "", "All")>
            <cfset sCleanTitle = replaceNoCase(sCleanTitle, "]", "", "All")>
            <cfset sCleanTitle = replaceNoCase(sCleanTitle, "{", "", "All")>
            <cfset sCleanTitle = replaceNoCase(sCleanTitle, "}", "", "All")>
            <cfset sCleanTitle = replaceNoCase(sCleanTitle, ".", "", "All")>
            <cfset sCleanTitle = replaceNoCase(sCleanTitle, ",", "", "All")>
            <cfset sCleanTitle = replaceNoCase(sCleanTitle, "?", "", "All")>
            <cfset sCleanTitle = replaceNoCase(sCleanTitle, "<", "", "All")>
            <cfset sCleanTitle = replaceNoCase(sCleanTitle, ">", "", "All")>
            <cfset sCleanTitle = replaceNoCase(sCleanTitle, "+", "", "All")>
            <cfset sCleanTitle = replaceNoCase(sCleanTitle, "+", "", "All")>

            <!--- --->
            <cfset sURL = "http://api.plos.org/search?q=title:'#sCleanTitle#'&fl=id,title,alternate_title&wt=json">
            <cfhttp url="#sURL#" method="get">
            <cfset jResponse = deserializeJSON(cfhttp.filecontent)>

            <!--- --->
            <cfset bFound = false>
            <cfloop array="#jResponse.response.docs#" index="stPaper">
                <cfif qPaper.title eq stPaper.title>
                    <cfset bFound = true>
                    <cfexit>
                </cfif>
            </cfloop>

            <!--- --->
            <cfif bFound>
                <strong>+++ #qPaper.currentrow# #qPaper.title#</strong><br>
            <cfelse>
                - #qPaper.currentrow#<br>
            </cfif>
        <cfcatch>
            cfcatch<br>
        </cfcatch>
    </cftry>
    </cfloop>
</div>
</cfoutput>
