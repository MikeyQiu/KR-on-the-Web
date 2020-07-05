<!--- --->
<cfsetting RequestTimeout = "0">

<!--- --->
<cfset tc0 = getTickCount()>

<!--- --->
<cfquery name="qPaper" datasource="#sDSN#" result="stResult" maxrows="1">
    SELECT      paper.id
    ,           paper.paper_url
    ,           paper.authorcount
    FROM        paper
    WHERE       paper.authorcount = -1
</cfquery>

<!--- --->
<cfoutput>#(getTickCount()-tc0)/1000#</cfoutput>
<hr>

<!--- --->
<cfquery name="qCount" datasource="#sDSN#" result="stResult">
    SELECT      paper_author.paper_url
    ,           Count(paper_author.author) AS iCount
    FROM        paper
    INNER JOIN  paper_author ON paper_author.paper_url = paper.paper_url
    WHERE       paper.id IN (#valueList(qPaper.id)#)
    GROUP BY    paper.paper_url, paper.id
</cfquery>

<!--- --->
<cfloop query="qCount">

    <!--- --->
    <cfquery name="qCount" datasource="#sDSN#" result="stResult">
        SELECT      Count(paper_author.author) AS iCount
        FROM        paper
        INNER JOIN  paper_author ON paper_author.paper_url = paper.paper_url
        WHERE       paper.id = #qPaper.id#
        GROUP BY    paper.paper_url, paper.id
    </cfquery>
    <cfdump var="#stResult#">

    <cfif qCount.iCount eq "">
        <cfset iAuthorCount = 0>
    <cfelse>
        <cfset iAuthorCount = qCount.iCount>
    </cfif>

    <!--- --->
    <cfquery name="qUpdate" datasource="#sDSN#" result="stResult">
        UPDATE  paper
        SET     paper.authorcount   =  #iAuthorCount#
        WHERE   paper.paper_url     = '#qPaper.paper_url#'
    </cfquery>

    <!--- --->
    <cfoutput>
        #(getTickCount()-tc0)/1000# - #qPaper.id#<br>
        <cfflush interval="10">
    </cfoutput>
</cfloop>

<!--- --->
<cfquery name="qRemaining" datasource="#sDSN#" result="stResult" maxrows="1">
    SELECT      COUNT(paper.id) AS iCount
    FROM        paper
    WHERE       paper.authorcount = -1
</cfquery>
<cfoutput><br>#qRemaining.iCount# remaining</cfoutput>