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
<cfoutput>

<!-- Page Content -->
<div class="container mb-5 mt-2" id="page">
    <!--- --->
    <h3>MAKG - Find authors by paper</h3>
    <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="index.cfm">Home</a></li>
        <li class="breadcrumb-item active"><a href="makgFindAuthorsByPaper.cfm">MAKG - Find authors by paper</a></li>
        <li class="breadcrumb-item active">Result</li>
    </ol>

    <!--- --->
    <cfset sFiller = repeatString("<!-- -->", 100)>

    <!--- getFullTextForPapers.cfm --->
    <cfif trim(form.papers) eq "">
        <cflocation  url="index.cfm">
    </cfif>

    <!--- Transform all list separators to comma's. --->
    <cfset form.papers = trim(form.papers)>
    <!--- <cfset form.papers = replaceNoCase(form.papers, ";", ",", "All")> --->
    <cfset form.papers = replaceNoCase(form.papers, chr(13) & chr(10), "|", "All")>
    <cfset form.papers = replaceNoCase(form.papers, chr(13), "|", "All")>
    <cfset form.papers = replaceNoCase(form.papers, chr(10), "|", "All")>
    <cfset form.papers = REreplaceNoCase(form.papers, ",+", ",", "All")>
    <!--- <cfset form.papers = REreplaceNoCase(form.papers, " +", "", "All")> --->

    <div class="mt-1"><cfoutput>Input list: #form.papers#<hr></cfoutput></div>

    <!--- --->
    <cfif listLen(form.papers, "|") eq 0>
        <cfset form.papers = listAppend(form.papers, -1, "|")>
    </cfif>

    <!--- --->
    <cfset lPapers = form.papers>
    
    <!--- --->
    <cfset lPapers = ListQualify(lPapers, '"', "|")>
    <cfset lPapers = replace(form.papers, "|", ",", "All")>
    <cfset lPapers = ListQualify(lPapers, '"', ",")>

    <!--- --->
    <cfquery name="qPaper" datasource="#sDSN#" maxrows=10>
        SELECT      paper.id
        ,           paper.title
        ,           paper.paper_url
        ,           paper.url_pdf
        ,           paper.arxiv_id
        FROM        paper
        WHERE       paper.title IN (#lPapers#)
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
        PREFIX datacite: <http://purl.org/spar/datacite/>
    
        SELECT ?paper ?doi ?author ?authorname
        WHERE {
            ?paper dcterms:title "#qPaper.title#"^^xsd:string.

            OPTIONAL{
                ?paper datacite:doi ?doi.
            }

            OPTIONAL{
                    ?paper dcterms:creator ?author.
                    ?author foaf:name ?authorname.
                }
            }
        '>
<!---
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
            ?paper dcterms:title "#qPaper.title#"^^xsd:string.
            
            OPTIONAL{
                    ?paper dcterms:creator ?author.
                    ?author foaf:name ?authorname.
                }
            }
        '>
 --->

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
            - This paper was not found in the Microsoft Academic Knowledge Graph (or it did not have any authors listed).<br>
        <cfelse>
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
                + author <strong>#stAuthor.authorname.value#</strong> was found (<em>#stAuthor.author.value#</em>).<br>
            <cfelse>
                - author <strong>#stAuthor.authorname.value#</strong> was not found...<br>
            </cfif>
        </cfloop>

        <hr>
    </cfloop>

    <p>Notes for the report:</p>
    <ul>
        <li>Matching 1) authors from the paperswithcode.com dataset and 2) the MAKG dataset sometimes requires that initials (as in Harry <b>S.</b> Truman) are removed from the author name before they can be matched. So the logic that matches the two author instances removes the initials when it attempts to make a match.</li>
        <li></li>
    </ul>

    </cfoutput>
</div>
</body>
</html>