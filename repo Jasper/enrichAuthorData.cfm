<!--- --->
<cfoutput>
    
<!--- --->
<cfsetting RequestTimeout = "0">
<cfset iAuthorCount = 10>

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
    SELECT      Count(author.resource_id) AS iCount
    FROM        author
    WHERE       author.makg_sameAs <> 'notfound'
</cfquery>

<!--- --->
<cfquery name="qCountRemaining" datasource="#sDSN#" maxrows="#iAuthorCount#">
    SELECT      Count(author.resource_id) AS iCount
    FROM        author
    WHERE       author.makg_sameAs <> 'notfound'
    AND         (
                    author.makg_rank    = -1 OR
                    makg_papercount     = -1 OR
                    makg_citationcount  = -1
                )
    ORDER BY    author.resource_id ASC
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
            <li class="breadcrumb-item active">Enrich author data using the MAKG</li>
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

        <p>#qCountRemaining.iCount#/#qCountAll.iCount# = #iPercentageDone#%</p>

        <!--- --->
        <cfquery name="qAuthor" datasource="#sDSN#" maxrows="#iAuthorCount#">
            SELECT      author.*
            FROM        author
            WHERE       author.makg_sameAs <> 'notfound'
            AND         (
                            author.makg_rank    = -1 OR
                            makg_papercount     = -1 OR
                            makg_citationcount  = -1
                        )
            ORDER BY    author.resource_id ASC
        </cfquery>
    
        <table class="table table-condensed">
            <tr>
                <th>Resource ID</th>
                <th>Name</th>
                <th>Citation count</th>
                <th>Paper count</th>
                <th>Rank</th>
            </tr>
        <cfloop query="qAuthor">
            <!--- --->
            <tr>

            <!--- --->
            <cfhttp url="#qAuthor.makg_sameAs#" method="get"></cfhttp>
            <cfset sText = cfhttp.filecontent>
            <cfset sText = reReplaceNoCase(sText, " +", "=", "All")>

            <!--- Citation count --->
            <cfset stCitationCount = reFindNoCase("citationCount=[\d]+", sText, 1,"true", "all")>
            <cfset iCitationCount = replaceNoCase(stCitationCount[1].match[1], "citationCount=", "")>

            <!--- Paper count --->
            <cfset stPaperCount = reFindNoCase("paperCount=[\d]+", sText, 1,"true", "all")>
            <cfset iPaperCount = replaceNoCase(stPaperCount[1].match[1], "paperCount=", "")>
            
            <!--- Rank --->
            <cfset stRank = reFindNoCase("rank=[\d]+", sText, 1,"true", "all")>
            <cfset iRank = replaceNoCase(stRank[1].match[1], "rank=", "")>

            <!--- --->
            <cftry>
                <cfquery name="qUpdate" datasource="#sDSN#" result="stResult">
                    UPDATE  author
                    SET     author.makg_paperCount      = #iPaperCount#
                    ,       author.makg_citationCount   = #iCitationCount#
                    ,       author.makg_rank            = #iRank#
                    WHERE   author.resource_id          = '#qAuthor.resource_id#';
                </cfquery>
                <cfcatch>
                    <script>
                        location.href='enrichAuthorData.cfm';
                    </script>
                </cfcatch>
            </cftry>
            <tr>
                <td>#qAuthor.resource_id#</td>
                <td>#qAuthor.name#</td>
                <td>#iCitationCount#</td>
                <td>#iPaperCount#</td>
                <td>#iRank#</td>
            </tr>
        </cfloop>
        </table>

        <cfset iDuration = getTickCount() - tc1>
        <cfset iRemainingduration = (qCountRemaining.iCount * iDuration/iAuthorCount)/1000/3600>
        #iDuration# ms - #numberformat(iRemainingduration, "99.0")# hour to go<br>
    
        <script>
            location.href='enrichAuthorData.cfm';
        </script>

        <cfabort>
    <cfcatch>
        <cfdump var="#cfcatch#">
    </cfcatch>
</cftry>
</body>
</html>

<!--- --->
</cfoutput>
