<cfabort>
<!--- --->
<cfoutput>
    
<!--- --->
<cfsetting RequestTimeout = "0">
<cfset iAuthorCount = 100>

<!--- --->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="">
  <meta name="author" content="">

  <title>Match papers to the MAKG</title>

	<!-- Bootstrap core CSS -->
	<link href="vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
	<link href="css/dscs.css" rel="stylesheet">
	<link href="css/bootstrap-slider.min.css" rel="stylesheet">
	<link href="css/jquery.json-viewer.css" rel="stylesheet">
    <link rel="stylesheet" href="css/modal-video.min.css">
    <script src="https://kit.fontawesome.com/c80dff83b6.js" crossorigin="anonymous"></script>
    <link href="https://unpkg.com/gijgo@1.9.13/css/gijgo.min.css" rel="stylesheet" type="text/css" />    
    <link rel="stylesheet" href="css/spinner.css">
    <style>
        body {font-size:0.7em;}
    </style>
</head>
<body>

<!--- --->
<cfquery name="qCountAll" datasource="#sDSN#" maxrows="#iAuthorCount#">
    SELECT      Count(paper.resource_id) AS iCount
    FROM        paper
    WHERE       paper.makg_sameAs <> 'notfound'
</cfquery>

<!--- --->
<cfquery name="qCountRemaining" datasource="#sDSN#" maxrows="#iAuthorCount#">
    SELECT      Count(paper.resource_id) AS iCount
    FROM        paper
    WHERE       paper.makg_sameAs <> 'notfound'
    AND         paper.makgpagedone = 0
    ORDER BY    paper.resource_id ASC
</cfquery>

<!--- --->
<cfset tc1 = getTickCount()>

<!--- --->
<cftry>
    <!--- Page Content --->
    <div class="container mb-5 mt-2" id="page">
        <!--- --->
        <h3>Match papers to the MAKG</h3>
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="index.cfm">Home</a></li>
            <li class="breadcrumb-item active">Enrich paper data using the MAKG</li>
        </ol>

        <cfset iPercentageDone = int(((qCountAll.iCount-qCountRemaining.iCount)/qCountAll.iCount)*100)>

        <!--- --->
        <cfoutput>
            <div class="progress ptn mtn mbm">
                <div class="progress-bar progress-bar-info progress-bar-striped" role="progressbar" aria-valuenow="#iPercentageDone#" aria-valuemin="0" aria-valuemax="100" style="width: #iPercentageDone#%">
                <span class="sr-only">#iPercentageDone#% Complete</span>
                </div>
            </div>
        </cfoutput>

        <p>#100*(1-(qCountRemaining.iCount/qCountAll.iCount))# | #qCountRemaining.iCount#/#qCountAll.iCount# = #iPercentageDone#%</p>

        <!--- --->
        <cfquery name="qPaper" datasource="#sDSN#" maxrows="#iAuthorCount#">
            SELECT      paper.*
            FROM        paper
            WHERE       paper.makg_sameAs <> 'notfound'
            AND         paper.makgpagedone    = 0
        </cfquery>
    
        <table class="table table-condensed">
            <tr>
                <th>Resource ID</th>
                <th>Title</th>
                <th>DOI</th>
                <th>Language</th>
                <th>Startpage</th>
                <th>Endpage</th>
                <th>Citation<br>count</th>
                <th>Reference<br>count</th>
                <th>Pubdate</th>
            </tr>
        <cfloop query="qPaper">
            <!--- --->
            <tr>

            <!--- --->
            <cfhttp url="#qPaper.makg_sameAs#" method="get">
            <cffile action="write" file="#expandPath("rdf.rxt")#" output="#cfhttp.fileContent#">

            <cfset sText = cfhttp.filecontent>
            <cfset sText = reReplaceNoCase(sText, " +", "=", "All")>
            <cfset sText = replaceNoCase(sText, "^", "=", "All")>

            <!--- makg_doi --->
            <cfset stDOI                = reFindNoCase(':doi=".*"', sText, 1,"true", "all")>
            <cfset sDOI                 = replaceNoCase(stDOI[1].match[1], ":doi=", "")>
            <cfset sDOI                 = replaceNoCase(sDOI, "doi=", "")>
            <cfset sDOI                 = replaceNoCase(sDOI, '"', "", "All")>
            <cfset sDOI                 = trim(sDOI)>

            <!--- makg_language --->
            <cfset stLanguage           = reFindNoCase(':language=".*"==xsd:language', sText, 1,"true", "all")>
            <cfset sLanguage            = replaceNoCase(stLanguage[1].match[1], ":language=", "")>
            <cfset sLanguage            = replaceNoCase(sLanguage, "==xsd:language", "")>
            <cfset sLanguage            = replaceNoCase(sLanguage, '"', "", "All")>
            <cfset sLanguage            = replaceNoCase(sLanguage, '^^xsd:language', "", "All")>
            <cfset sLanguage            = trim(sLanguage)>

            <!--- makg_startpage --->
            <cfset stStartPage          = reFindNoCase("startingPage=[\d]+", sText, 1,"true", "all")>
            <cfset iStartPage           = replaceNoCase(stStartPage[1].match[1], "startingPage=", "")>
            <cfset iStartPage           = trim(iStartPage)>

            <!--- makg_endpage --->
            <cfset stEndPage            = reFindNoCase("endingPage=[\d]+", sText, 1,"true", "all")>
            <cfset iEndPage             = replaceNoCase(stEndPage[1].match[1], "endingPage=", "")>
            <cfset iEndPage             = trim(iEndPage)>

            <!--- makg_citationcount --->
            <cfset stCitationCount      = reFindNoCase("citationCount=[\d]+", sText, 1,"true", "all")>
            <cfset iCitationCount       = replaceNoCase(stCitationCount[1].match[1], "citationCount=", "")>
            <cfset iCitationCount       = trim(iCitationCount)>

            <!--- makg_referencecount --->
            <cfset stReferenceCount     = reFindNoCase("referenceCount=[\d]+", sText, 1,"true", "all")>
            <cfset iReferenceCount       = replaceNoCase(stReferenceCount[1].match[1], "referenceCount=", "")>
            <cfset iReferenceCount       = trim(iReferenceCount)>

            <!--- makg_publicationdate --->
            <cfset stPublicationdate      = reFindNoCase('publicationDate="\d{4}-\d{2}-\d{2}"', sText, 1,"true", "all")>
            <cfset sPublicationdate       = replaceNoCase(stPublicationdate[1].match[1], "publicationDate=", "")>
            <cfset sPublicationdate       = trim(sPublicationdate)>
            <cfset sPublicationdate       = replace(sPublicationdate, '"', '', 'All')>
            <cfset dPublicationdate       = createDate(listGetAt(sPublicationdate, 1, "-"), listGetAt(sPublicationdate, 2, "-"), listGetAt(sPublicationdate, 3, "-"))>

            <!---             --->

                <cfoutput>sDOI              = #sDOI#<br></cfoutput>
                <cfoutput>sLanguage         = #sLanguage#<br></cfoutput>
                <cfoutput>iStartPage        = #iStartPage#<br></cfoutput>
                <cfoutput>iEndPage          = #iEndPage#<br></cfoutput>
                <cfoutput>iCitationCount    = #iCitationCount#<br></cfoutput>
                <cfoutput>iReferenceCount    = #iReferenceCount#<br></cfoutput>
                <cfoutput>dPublicationdate    = #dPublicationdate#<br></cfoutput>

            <!--- --->
                <cfquery name="qUpdate" datasource="#sDSN#" result="stResult">
                    UPDATE  paper
                    SET     makg_doi                    = '#sDOI#'
                    ,       makg_language               = '#sLanguage#'
                    ,       makgpagedone                = 1
                <cfif isNumeric(iStartPage)>
                    <cfif iStartPage lt 100000>
                    ,       makg_startpage              =  #iStartPage#
                    </cfif>
                </cfif>
                <cfif isNumeric(iEndPage)>
                    <cfif iEndPage lt 100000>
                    ,       makg_endpage                =  #iEndPage#
                    </cfif>
                </cfif>
                <cfif isNumeric(iCitationCount)>
                    ,       makg_citationcount          =  #iCitationCount#
                </cfif>
                <cfif isNumeric(iReferenceCount)>
                    ,       makg_referencecount         =  #iReferenceCount#
                </cfif>
                <cfif isDate(dPublicationdate)>
                    ,       makg_publicationdate        =  #dPublicationdate#
                </cfif>

                    WHERE   paper.resource_id           = '#qPaper.resource_id#';
                </cfquery>
                <cfdump var="#stResult#">
                <cfabort>

                <cftry>
                    <cfcatch>
                    <script>
                        // location.href='enrichAuthorData.cfm';
                    </script>
                </cfcatch>
            </cftry>

            <tr>
                <td>#qPaper.resource_id#</td>
                <td>#qPaper.title#</td>
                <td>#sDOI#</td>
                <td>#sLanguage#</td>
                <td>#iStartPage#</td>
                <td>#iEndPage#</td>
                <td>#iCitationCount#</td>
                <td>#iReferenceCount#</td>
                <td>#dPublicationdate#</td>
            </tr>
        </cfloop>
        </table>
   
        <cfset iDuration = getTickCount() - tc1>
        <cfset iRemainingduration = (qCountRemaining.iCount * iDuration/iAuthorCount)/1000/3600>
        #iDuration# ms - #numberformat(iRemainingduration, "99.0")# hour to go<br>
    
        <script>
            // location.href='enrichPaperData.cfm';
        </script>
    <cfcatch>
        <cfdump var="#cfcatch#">
        <cfabort>
        <script>
            <!--- location.href='enrichPaperData.cfm'; --->
        </script>
    </cfcatch>
</cftry>
</body>
</html>

<!--- --->
</cfoutput>
