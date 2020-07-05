<!--- --->
Aborted for safety.
<cfabort>

<!--- --->
<cfsetting RequestTimeout = "0">
<cfoutput>

<!--- --->
<cfquery name="qClear" datasource="#sDSN#" result="stResult">DELETE FROM repo</cfquery>

<!--- --->
<cfset sFileName = "links-between-papers-and-code.json">
Processing '#sFileName#'<br>
<br>

<!--- Open the file object. --->
<cfset oFile = FileOpen(expandPath(sFileName), "read")>

<cfset i = 1>
<cfset iPaperCount = 1>
<cfloop condition="FileisEOF(oFile) eq 'NO'">
    <!--- --->
    <cfset sLine = trim(FileReadLine(oFile))>

    <!--- --->
    <cfswitch expression="#sLine#">
        <!--- --->
        <cfcase value="[,]"></cfcase>

        <!--- --->
        <cfcase value="{">
            <!--- Start new JSON string. --->
            <cfset sJSON = sLine>
        </cfcase>

        <!--- --->
        <cfcase value="}|}," delimiters="|">
            <!--- Finish the JSON string. --->
            <cfset sJSON = sJSON & "}">
            
            <!--- --->
            <cfset stItem = DeserializeJSON(sJSON)>

            <!--- Some papers do not have all properties. Make sure they do. --->
            <cfif NOT structKeyExists(stItem, "paper_arxiv_id")>
                <cfset stItem.paper_arxiv_id = "">
            </cfif>
            <cfif NOT structKeyExists(stItem, "paper_title")>
                <cfset stItem.title = "">
            </cfif>
            <cfif NOT structKeyExists(stItem, "paper_url_pdf")>
                <cfset stItem.url_pdf = "">
            </cfif>

            <!--- --->
            <cfset stItem.paper_title     = replace(stItem.paper_title, "'", "", "All")>
            <cfset stItem.paper_title     = replace(stItem.paper_title, "\", "", "All")>

            <!--- --->
            Inserting paper ###iPaperCount#: #stItem.paper_title#<br>

            <!--- Insert the repo.  --->
            <cfquery name="qInsert" datasource="#sDSN#" result="stResult">
                INSERT INTO repo   (
                                        paper_url
                ,                       paper_title
                ,                       paper_arxiv_id
                ,                       paper_url_abs
                ,                       paper_url_pdf
                ,                       repo_url
                ,                       mentioned_in_paper
                ,                       mentioned_in_github
                ,                       framework
                                    )
                VALUES              (
                                        '#stItem.paper_url#'
                ,                       '#stItem.paper_title#'
                ,                       '#stItem.paper_arxiv_id#'
                ,                       '#stItem.paper_url_abs#'
                ,                       '#stItem.paper_url_pdf#'
                ,                       '#stItem.repo_url#'
                ,                       '#stItem.mentioned_in_paper#'
                ,                       '#stItem.mentioned_in_github#'
                ,                       '#stItem.framework#'
                                    )
            </cfquery>
            <cfset iKey = stResult.generatedkey>

            <cfset iPaperCount = iPaperCount + 1>
        </cfcase>

        <!--- --->
        <cfdefaultcase>
            <!--- Start new JSON string. --->
            <cfset sJSON = sJSON & sLine>
        </cfdefaultcase>
    </cfswitch>

    <!--- --->
    <cfflush interval="255">

    <!--- --->
    <cfset i = i + 1>
    <cfif i gt 100000000000000>
        
        <cfexit>
    </cfif>
</cfloop>

<br>
Finish
</cfoutput>
