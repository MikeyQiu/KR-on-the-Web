<cfquery name="qAuthor" datasource="#sDSN#" maxrows="100">
    SELECT      author.*
    FROM        author
    ORDER BY    author.name ASC
</cfquery>

<!--- --->
<cfoutput>
<cfloop query="qAuthor">
    <cfif qAuthor.resource_id neq "A#numberformat(qAuthor.currentrow, "00000")#">
        ------------------ #qAuthor.resource_id#<br>
    <cfelse>
        #qAuthor.resource_id#<br>
    </cfif>
</cfloop>
</cfoutput>
