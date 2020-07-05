<!--- --->
<cfoutput>
    
<!--- --->
<cfsetting RequestTimeout = "0">
<cfset iPaperCount = 10>

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
<cfset tc1 = getTickCount()>

<!--- --->
<cftry>
    <!--- Page Content --->
    <div class="container mb-5 mt-2" id="page">
        <!--- --->
        <h3>Match papers to the MAKG</h3>
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="index.cfm">Home</a></li>
            <li class="breadcrumb-item active">Match papers to the MAKG</li>
        </ol>

        <!--- --->
        <cfquery name="qCount" datasource="#sDSN#">
            SELECT  Count(paper.id) AS iCount
            FROM    paper
            WHERE   paper.makg_sameAs = 'unprocessed'
        </cfquery>

        <!--- --->
        <cfquery name="qCountAll" datasource="#sDSN#">
            SELECT  Count(paper.id) AS iCount
            FROM    paper
        </cfquery>

        <!--- --->
        <cfset iPercentageDone = numberFormat((1-qCount.iCount/qCountAll.iCount)*100, "999")>

        <!--- --->
        <cfoutput>
            <div class="progress ptn mtn mbm">
                <div class="progress-bar progress-bar-info progress-bar-striped" role="progressbar" aria-valuenow="#iPercentageDone#" aria-valuemin="0" aria-valuemax="100" style="width: #iPercentageDone#%">
                <span class="sr-only">#iPercentageDone#% Complete</span>
                </div>
            </div>
        </cfoutput>

        <p class="mbn">
            #qCount.iCount# papers left to process...
            (about #int(qCount.iCount/7000)# hours to go)
            -
            #iPercentageDone#%
        </p>

        <!--- --->
        <cfquery name="qPaper" datasource="#sDSN#" maxrows="#iPaperCount#">
            SELECT      paper.id
            ,           paper.title
            ,           paper.paper_url
            ,           paper.url_pdf
            ,           paper.arxiv_id
            FROM        paper
            WHERE       paper.makg_sameAs = 'unprocessed'
        </cfquery>

        <!--- --->
        <cfloop query="qPaper">
            <!--- Query (local) the authors scraped from paperswithcode.com. --->
            <cfquery name="qLocalAuthor" datasource="#sDSN#" result="qResult">
                SELECT      author.`name`
                FROM        paper_author
                INNER JOIN  author ON paper_author.author = author.`name`
                WHERE       paper_author.paper_url = '#qPaper.paper_url#'
            </cfquery>

            <!--- Remove initials and replace multiple spaces with single spaces. --->
            <cfloop query="qLocalAuthor">
                <cfset sScrubbedName = REReplaceNoCase(qLocalAuthor.name, "[A-Z]\.+", "", "All")>
                <cfset sScrubbedName = REReplaceNoCase(sScrubbedName, " +", " ", "All")>
                <cfset sScrubbedName = trim(sScrubbedName)>
                <cfset res = querySetCell(qLocalAuthor, 'name', sScrubbedName, qLocalAuthor.currentrow)>
            </cfloop>

            <!--- --->
            <strong>#qPaper.title#</strong><br>
            <cfset sSPARQLQuery = '
            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns##>
            PREFIX magc: <http://ma-graph.org/class/>
            PREFIX dcterms: <http://purl.org/dc/terms/>
            PREFIX foaf: <http://xmlns.com/foaf/0.1/>
            PREFIX fabio: <http://purl.org/spar/fabio/>
            PREFIX prism: <http://prismstandard.org/namespaces/1.2/basic/>
            PREFIX xsd: <http://www.w3.org/2001/XMLSchema##>
        
            SELECT ?paper ?author ?authorname
            WHERE {
                ?paper dcterms:title "#replacenocase(qPaper.title, '"', '', 'All')#"^^xsd:string.
                
                OPTIONAL{
                        ?paper dcterms:creator ?author.
                        ?author foaf:name ?authorname.
                    }
                }
            '>

            <cfset sQueryURL = "http://ma-graph.org/sparql?default-graph-uri=&query=">
            <cfset sQueryURL = sQueryURL & urlEncodedFormat(sSPARQLQuery)>
            
            <cfset sQueryURL = sQueryURL & "&format=json">
            <cfset sQueryURL = sQueryURL & "&timeout=0">
            <cfset sQueryURL = sQueryURL & "&debug=on">
            
            <!--- Query the MAKG SPARQL endpoint. --->
            <cfhttp url     = "#sQueryURL#"
                    method  = "GET">
            
            <cfset o = deserializeJSON(cfhttp.filecontent)>
            <cfif arrayLen(o.results.bindings) eq 0>
                <!--- The paper was not found. Mark the paper as not found in the MAKG. --->
                <cfquery name="qUpdate" datasource="#sDSN#" result="stResult">
                    UPDATE  paper
                    SET     paper.makg_sameAs  = 'notfound'
                    WHERE   paper.id           = #qPaper.id#
                </cfquery>
                        
                - This paper was not found in the Microsoft Academic Knowledge Graph (or it did not have any authors listed).<br>
            <cfelse>
                <!--- The paper was not found. Mark the paper as not found in the MAKG. --->
                <cfquery name="qUpdate" datasource="#sDSN#" result="stResult">
                    UPDATE  paper
                    SET     paper.makg_sameAs  = '#o.results.bindings[1].paper.value#'
                    WHERE   paper.id           = #qPaper.id#
                </cfquery>

                (<em>#o.results.bindings[1].paper.value#</em>)<br>
                <br>
            </cfif>
    
            <!--- --->
            <cfloop array="#o.results.bindings#" index="stAuthor">
                <!--- Scrub the local name. --->
                <cfset sScrubbedLocalName = REReplaceNoCase(stAuthor.authorname.value, "[A-Z]\.+", "", "All")>
                <cfset sScrubbedLocalName = REReplaceNoCase(sScrubbedLocalName, " +", " ", "All")>
                <cfset sScrubbedLocalName = trim(sScrubbedLocalName)>

                <!--- --->
                <cfquery name="qFind" dbtype="query" result="stResult">
                    SELECT  qLocalAuthor.name
                    FROM    qLocalAuthor
                    WHERE   qLocalAuthor.name = '#sScrubbedLocalName#'
                </cfquery>

                <!--- --->
                <cfif qFind.recordcount eq 1>
                    <!--- --->
                    <cfquery name="qUpdate" datasource="#sDSN#" result="stResult">
                        UPDATE  author
                        SET     author.makg_sameAs  = '#stAuthor.author.value#'
                        WHERE   author.name         = '#qFind.name#'
                    </cfquery>

                    + author <strong>#stAuthor.authorname.value#</strong> was found (<em>#stAuthor.author.value#</em>).<br>
                <cfelse>
                    - author <strong>#stAuthor.authorname.value#</strong> was not found...<br>
                </cfif>
            </cfloop>

            <hr>
            <cfflush interval="1024">
        </cfloop>

        <cfset tc2 = getTickCount() - tc1>
        #numberformat(tc2/1000, "9999.00")# seconds

        <script>
            location.href='matchPapersToMAKG.cfm';
        </script>
    </div>
    
    <!--- --->
    <cfcatch>
        <script>
            location.href='matchPapersToMAKG.cfm';
        </script>
    </cfcatch>
</cftry>

</body>
</html>

<!--- --->
</cfoutput>
