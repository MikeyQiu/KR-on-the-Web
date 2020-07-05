<!--- --->
<cfsetting RequestTimeout = "0">
<cfoutput>

<!--- --->
<cfquery name="qClear" datasource="#sDSN#">DELETE FROM paper_author</cfquery>
<cfquery name="qClear" datasource="#sDSN#">DELETE FROM author</cfquery>

<!--- --->
<cfquery name="qAuthors" datasource="#sDSN#">
    SELECT  author.*
    FROM    author
</cfquery>

<!--- --->
<cfset sFileName = "papers-with-abstracts.json">

<!--- --->
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
            <cfif NOT structKeyExists(stItem, "arxiv_id")>
                <cfset stItem.arxiv_id = "">
            </cfif>
            <cfif NOT structKeyExists(stItem, "title")>
                <cfset stItem.title = "">
            </cfif>
            <cfif NOT structKeyExists(stItem, "abstract")>
                <cfset stItem.abstract = "">
            </cfif>
            <cfif NOT structKeyExists(stItem, "url_pdf")>
                <cfset stItem.url_pdf = "">
            </cfif>

            <cfset stItem.title     = replace(stItem.title, "'", "", "All")>
            <cfset stItem.abstract  = replace(stItem.abstract, "'", "", "All")>

            <cfset stItem.title     = replace(stItem.title, "\", "", "All")>
            <cfset stItem.abstract  = replace(stItem.abstract, "\", "", "All")>

            <!--- --->
            <strong>#stItem.title#</strong><br>

            <!--- --->
            <cfloop array="#stItem.authors#" index="sAuthor">
                <cfset sAuthor = replace(sAuthor, "{", "", "All")>
                <cfset sAuthor = replace(sAuthor, "}", "", "All")>
                <cfset sAuthor = replace(sAuthor, "^", "", "All")>
                <cfset sAuthor = replace(sAuthor, "\", "", "All")>
                <cfset sAuthor = replace(sAuthor, "'", "", "All")>
                <cfset sAuthor = replace(sAuthor, '"', "", "All")>
                <cfset sAuthor = REreplace(sAuthor, " +", " ", "All")>
                <cfset sAuthor = trim(sAuthor)>

                <!--- --->
                <cfquery name="qAuthor" dbtype="query">
                    SELECT  qAuthors.*
                    FROM    qAuthors
                    WHERE   qAuthors.name = '#sAuthor#'
                </cfquery>

                <!--- --->
                <cfif qAuthor.recordcount eq 0>
                    <!--- --->
                    <cfquery name="qInsertAuthor" datasource="#sDSN#">
                        INSERT INTO author   (
                                                name
                                            )
                        VALUES              (
                                                '#sAuthor#'
                                            )
                    </cfquery>

                    <!--- --->
                    <cfquery name="qAuthors" datasource="#sDSN#">
                        SELECT  author.*
                        FROM    author
                    </cfquery>                    
                    Paper #iPaperCount# | #sAuthor#<br>
                </cfif>

                <!--- --->
                <cfquery name="qInsert" datasource="#sDSN#">
                    INSERT INTO paper_author    (
                                                    paper_url
                    ,                               author
                                                )
                    VALUES                      (
                                                    '#stItem.paper_url#'
                    ,                               '#sAuthor#'
                                               )
                </cfquery>
            </cfloop>
            <br>            
            <cfset iPaperCount = iPaperCount + 1>
            <cfflush interval="255">
        </cfcase>

        <!--- --->
        <cfdefaultcase>
            <!--- Start new JSON string. --->
            <cfset sJSON = sJSON & sLine>
        </cfdefaultcase>
    </cfswitch>

    <!--- --->
    <cfset i = i + 1>
    <cfif i gt 100000>
        
        <!--- <cfexit> --->
    </cfif>
</cfloop>
<br>
Finish
</cfoutput>
