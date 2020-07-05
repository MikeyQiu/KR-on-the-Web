<!--- --->
<cfsetting RequestTimeout = "0">

<!--- --->
<cfquery name="qID" datasource="#sDSN#">
    SELECT  MAX(uniquerepo.id) AS iMax
    FROM    uniquerepo
</cfquery>
<cfif qID.iMax eq "">
    <cfset iCurrentResourceID = 1>
<cfelse>
    <cfset iCurrentResourceID = qID.iMax>
</cfif>

<!--- --->
<cfquery name="qCount" datasource="#sDSN#">
    SELECT  COUNT(repo.repo_url) AS iCount
    FROM    repo
    WHERE   repo.processed = 0

    UNION

    SELECT  COUNT(repo.repo_url) AS iCount
    FROM    repo
    WHERE   repo.processed = 1
</cfquery>

<!--- --->
<cfquery name="qLine" datasource="#sDSN#">
    SELECT  repo.*
    FROM    repo
    WHERE   repo.processed = 0
    ORDER BY repo_url ASC
    LIMIT   0,100
</cfquery>

<cfoutput>
    <strong>
        #qCount.iCount[2]#/#qCount.iCount[1]# | #iCurrentResourceID#<hr>
    </strong>
</cfoutput>

<!--- --->
<cfset r = iCurrentResourceID>
<cfoutput>
    <cfloop query="#qLine#">
        <!--- --->
        <cfquery name="qFindRepo" datasource="#sDSN#">
            SELECT  uniquerepo.*
            FROM    uniquerepo
            WHERE   uniquerepo.repo_url = '#qLine.repo_url#'
        </cfquery>

        <!--- --->
        <cfif qFindRepo.recordcount eq 0>
            <!--- --->
            <br>Insert repo R#numberformat(r, "00000")#<br>
            <cfquery name="qInsert" datasource="#sDSN#">
                INSERT INTO uniquerepo (
                                            resource_id
                ,                           repo_url
                ,                           framework
                ,                           id
                                        ) 
                VALUES                  (
                                            'R#numberformat(r, "00000")#'
                ,                           '#qLine.repo_url#'
                ,                           '#qLine.framework#'
                ,                            #r#
                                        )
            </cfquery>
            <cfset r = r + 1>

            <!--- --->
            <cfquery name="qFindRepo" datasource="#sDSN#">
                SELECT  uniquerepo.*
                FROM    uniquerepo
                WHERE   uniquerepo.repo_url = '#qLine.repo_url#'
            </cfquery>
        </cfif>

        <!--- --->
        <cfquery name="qCheck" datasource="#sDSN#" result="stResult">
            SELECT  paper_repo.*
            FROM    paper_repo
            WHERE   paper_repo.repo_url             = '#qFindRepo.repo_url#'
            AND     paper_repo.mentionedInPaper     = '#qLine.mentioned_in_paper#'
            AND     paper_repo.mentionedInGithub    = '#qLine.mentioned_in_github#'
            AND     paper_repo.paper_url            = '#qLine.paper_url#'
        </cfquery>

        <!--- --->
        <cfif qCheck.recordcount eq 0>
            <!--- --->
            Insert relationship - #qFindRepo.repo_url# -> #qLine.paper_url#<br>
            <cfquery name="qInsert" datasource="#sDSN#">
                INSERT INTO paper_repo  (
                                             paper_url
                ,                            repo_url
                ,                            mentionedInPaper
                ,                            mentionedInGithub
                                        )
                VALUES                  (                    
                                            '#qLine.paper_url#' 
                ,                           '#qFindRepo.repo_url#'
                ,                           '#qLine.mentioned_in_paper#'
                ,                           '#qLine.mentioned_in_github#'
                                        )
            </cfquery>
        </cfif>

        <!--- --->
        <cfquery name="qUpdate" datasource="#sDSN#">
            UPDATE  repo
            SET     repo.processed  = 1
            WHERE   repo.paper_url  = '#qLine.paper_url#'
            AND     repo.repo_url   = '#qLine.repo_url#'
        </cfquery>

        <!--- --->
        <cfflush interval="1024">
    </cfloop>
    <script>
        location.href = location.href;
    </script>
</cfoutput>
