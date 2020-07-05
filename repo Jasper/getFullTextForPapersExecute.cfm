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
<cfset sManifest = "id;arxivid;resourceid;title;urlpdf" & chr(13) & chr(10)>
<cfparam name="form.includepdfs" default="0">

<!--- --->
<cfoutput>

<!-- Page Content -->
<div class="container mb-5 mt-2" id="page">
    <!--- --->
    <h3>MAKG - Find authors by paper</h3>
    <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="index.cfm">Home</a></li>
        <li class="breadcrumb-item"><a href="getFullTextForPapers.cfm">Get full text for papers</a></li>
        <li class="breadcrumb-item active">Result</li>
    </ol>

    <!--- --->
    <cfset sFiller = repeatString("<!-- -->", 100)>

    <!--- getFullTextForPapers.cfm --->
    <cfif trim(form.papers) eq "">
        <cflocation  url="index.cfm">
    </cfif>

    <!--- --->
    <cfdirectory action="list" directory="#expandPath(".")#" name="qDir">
    <cfloop query="qDir">
        <cfoutput>
            <cfif left(qDir.name, 5) eq "work_" AND qDir.type eq "Dir">
                <cftry>
                    <cfdirectory  directory="#expandPath(qDir.name)#" action="delete" recurse="true">
                    <cfcatch></cfcatch>
                </cftry>
            </cfif>
        </cfoutput>
    </cfloop>

    <!--- Transform all list separators to comma's. --->
    <cfset form.papers = trim(form.papers)>
    <cfset form.papers = replaceNoCase(form.papers, ";", ",", "All")>
    <cfset form.papers = replaceNoCase(form.papers, chr(10), ",", "All")>
    <cfset form.papers = replaceNoCase(form.papers, chr(13), ",", "All")>
    <cfset form.papers = REreplaceNoCase(form.papers, ",+", ",", "All")>
    <cfset form.papers = REreplaceNoCase(form.papers, " +", "", "All")>

    <div class="mt-1"><cfoutput>Input list: #form.papers#<hr></cfoutput></div>

    <cfset form.papers = listAppend(form.papers, -1)>

    <!--- --->
    <cfset lPapers = form.papers>

    <!--- --->
    <cfif find(".", listGetAt(lPapers, 1))>
        <cfset sMode = "arxiv">
        <cfset lPapers = ListQualify(lPapers, '"')>
    <cfelse>
        <cfset sMode = "id">
    </cfif>

    <!--- --->
    <cfquery name="qPaper" datasource="#sDSN#">
        SELECT      paper.id
        ,           paper.title
        ,           paper.url_pdf
        ,           paper.arxiv_id
        ,           paper.resource_id
        FROM        paper
        WHERE       paper.url_pdf <> ''
        <cfif sMode eq "arxiv">
            AND         paper.arxiv_id IN (#lPapers#)
        <cfelse>    
            AND         paper.id IN (#lPapers#)
        </cfif>
    </cfquery>
 
    <!--- Create a temp folder to work with files in. --->
    <cfset sNowHash = hash(now())>
    <cfset sWorkFolder = expandPath("work_" & sNowHash)>
    <cfdirectory action="create" directory="#sWorkFolder#">
    <cfdirectory action="create" directory="#sWorkFolder#/txt">
    <cfdirectory action="create" directory="#sWorkFolder#/pdf">

    <!--- --->
    <cfloop query="qPaper">
        <!--- --->
        <strong>#qPaper.title#</strong><br>
        <a href="#qPaper.url_pdf#" target="_blank">#qPaper.url_pdf#</a> <cfif trim(qPaper.arxiv_id) neq "">(arxiv: #qPaper.arxiv_id#)</cfif><br>#sFiller#<cfflush interval="255"> 

        <!--- --->
        <cftry>
                <cfhttp url         = "#qPaper.url_pdf#" 
                        method      = "GET" 
                        useragent   = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:75.0) Gecko/20100101 Firefox/75.0"
                        path        = "#sWorkFolder#/pdf"></cfhttp>
                <cfcatch>
                    The file could not be downloaded...<br>
                    Skipped this file...<br><br>
                    <cfcontinue>
                </cfcatch>
            </cftry>

            <!--- --->
            <cfset sPDFFileName = listGetAt(qPaper.url_pdf, listlen(qPaper.url_pdf, "/"), "/")>
            <cfset sTxtFileName = replace(sPDFFileName, ".pdf", ".txt")>

            <!--- --->
            <cfif NOT isPDFFile(sWorkFolder & "/pdf/" & sPDFFileName)>
                This file is not a valid PDF...<br>
                Skipping this file...<br><br>
            <cfcontinue>
            </cfif>

            - Downloaded pdf...<br>#sFiller#<cfflush interval="255">

            <!--- If the file was really downloaded... --->
            <cfpdf  action          = "extracttext"
                    source          = "#sWorkFolder & "/pdf/" & sPDFFileName#"
                    pages           = "*"
                    honourspaces    = "false"
                    overwrite       = "true"
                    type            = "string"
                    usestructure    = "false"
                    destination     = "#sWorkFolder & "/txt/" & sTxtFileName#">
            
                <!--- --->
                <cffile action="read" file="#sWorkFolder & "/txt/" & sTxtFileName#" variable="sText">
                - Extracted text from pdf...#sFiller#<br><cfflush interval="255"> 
                
                <!--- --->
                <cfset sText = reReplaceNoCase(sText, " +", " ", "All")>
                - Cleaned up text...#sFiller#<br><cfflush interval="255">
                
                <!--- --->
                <cffile action="write" file="#sWorkFolder & "/txt/" & sTxtFileName#" output="#sText#" nameconflict="overwrite">
                - Saved text to file... #sFiller#<br><cfflush interval="255">

                <cfset sManifest = sManifest & "#qPaper.id#;#arxiv_id#;#qPaper.resource_id#;#qPaper.title#;#qPaper.url_pdf#" & chr(13) & chr(10)>
        
                <!--- --->
                <br>
    </cfloop>

    <!--- --->
    <cfset sTxtFolder = sWorkFolder & "/txt/">
    <cfset sRootFolder = sWorkFolder>

    <!--- --->
    <cffile action="write" file="#sWorkFolder#/manifest.csv" output="#sManifest#">
 
    <!--- --->
    <cfif form.includepdfs eq 0>
        <cfdirectory  directory="#sWorkFolder#/pdf" action="delete" recurse="true">
    </cfif>

    <!--- --->
    <cftry>
        <cfzip file="#sWorkFolder#\archive.zip" source="#sRootFolder#">
        <cfcatch>
            No archive was created (reason: '#cfcatch.message# #cfcatch.detail#')<br><br>
            <cfabort>
        </cfcatch>
    </cftry>

    <hr>
    Save text files to archive... #sFiller#<br><cfflush interval="255">
    <br>
    <a class="btn btn-info" href="work_#sNowHash#\archive.zip">Download archive.zip</a>
    <!--- Delete the work folder. --->

    </cfoutput>
</div>
</body>
</html>