<!--- --->
Aborted for safety.
<cfabort>

<!--- --->
<cfsetting RequestTimeout = "0">
<cfoutput>

<!--- --->
<cfquery name="qClear" datasource="#sDSN#">DELETE FROM paper</cfquery>
<cfquery name="qClear" datasource="#sDSN#">DELETE FROM author</cfquery>
<cfquery name="qClear" datasource="#sDSN#">DELETE FROM paper_task</cfquery>
<cfquery name="qClear" datasource="#sDSN#">DELETE FROM task</cfquery>

<!--- --->
<cfquery name="qAuthors" datasource="#sDSN#">
    SELECT  author.*
    FROM    author
</cfquery>

<!--- --->
<cfquery name="qTasks" datasource="#sDSN#">
    SELECT  task.*
    FROM    task
</cfquery>

<!--- --->
<cfset sFileName = "papers-with-abstracts.json">
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
            <cfdump var="#arrayLen(stItem.authors)#">

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

            <!--- <cfdump var="#stItem#" expand="no"> --->

            <!--- --->
            Inserting paper ###iPaperCount#: #stItem.title#<br>

            <!--- Insert the paper.  --->
            <cfquery name="qInsert" datasource="#sDSN#" result="stResult">
                INSERT INTO paper   (
                                        arxiv_id
                ,                       paper_url
                ,                       title
                ,                       abstract
                ,                       url_abs
                ,                       url_pdf
                ,                       date
                ,                       authorcount
                                    )
                VALUES              (
                                        '#stItem.arxiv_id#'
                ,                       '#stItem.paper_url#'
                ,                       '#stItem.title#'
                ,                       '#stItem.abstract#'
                ,                       '#stItem.url_abs#'
                ,                       '#stItem.url_pdf#'
                <cfif isDate(stItem.date)>
                ,                       '#stItem.date#'
                <cfelse>
                ,                       NULL
                </cfif>
                ,                       #arrayLen(stItem.authors)#
                                    )
            </cfquery>
            <cfset iKey = stResult.generatedkey>

            <!--- Insert the tasks if necessary. --->
            <cfloop array="#stItem.tasks#" item="sTask">
                <!--- See if the author is listed already. --->
                <cfquery name="qTask" datasource="#sDSN#">
                    SELECT  task.*
                    FROM    task
                    WHERE   task.task    =   '#sTask#'
                </cfquery>

                <!--- --->
                <cfif qTask.recordcount eq 0>
                    <!--- Insert thenewly fond author. --->            
                    <cfquery name="qInsert" datasource="#sDSN#">
                        INSERT INTO task   (
                            task
                                            )
                        VALUES              (
                                                '#sTask#'
                                            )
                    </cfquery>

                    <!--- Update the task recordset in memory. --->
                    <cfquery name="qTasks" datasource="#sDSN#">
                        SELECT  task.*
                        FROM    task
                    </cfquery>            
                </cfif>

                <!--- Link the paper to the task. --->
                <cfquery name="qInsert" datasource="#sDSN#">
                    INSERT INTO paper_task   (
                                                paperid
                    ,                           task
                                            )
                    VALUES              (
                                                 #iKey#
                    ,                           '#sTask#'
                                        )
                </cfquery>                

                <!--- --->
                <cfflush interval="10">
            </cfloop>

            <cfset iPaperCount = iPaperCount + 1>
        </cfcase>

        <!--- --->
        <cfdefaultcase>
            <!--- Start new JSON string. --->
            <cfset sJSON = sJSON & sLine>
        </cfdefaultcase>
    </cfswitch>
    

    <!--- --->
    <cfset i = i + 1>
    <cfif i gt 1000>
        
        <!--- <cfexit> --->
    </cfif>
</cfloop>

<br>
Finish
</cfoutput>
