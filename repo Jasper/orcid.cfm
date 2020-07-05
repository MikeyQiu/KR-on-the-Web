<!--- 
    ORCID public API Tutotial: 
    https://members.orcid.org/api/basic-tutorial-searching-data-using-orcid-api-30

    Search for ORCID member by name.
    https://pub.orcid.org/v3.0/search?q=credit-name%3Ailaria%20tiddi

    Get a person's data.
    https://pub.orcid.org/v3.0/0000-0001-7116-9338/person

    Get external identifiers like for Scopus.
    https://pub.orcid.org/v3.0/0000-0001-7116-9338/external-identifiers
 --->
<!--- --->
<cfparam name="url.givennames" default = "ilaria">
<cfparam name="url.familyname" default = "tiddi">

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
 
<!-- Page Content -->
<div class="container mb-5 mt-2" id="page">
    <!--- --->
    <h3>Find the ORCID for a person</h3>
    <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="index.cfm">Home</a></li>
        <li class="breadcrumb-item active">Find the ORCID for a person</li>
    </ol>
    <p>Looking up the ORCID for a person in the ORCID Public API is a two step procedure. First we search by given name and family name (there are other options, but this combination seems to work the best). If a person was found, only the ORCID is returned, so to make sure we actually found the right person, we look up their given names and family name and compare those to our data.</p>
    <p>This procedure is far from perfect:</p>
    <p>
        <ol>
            <li>The author names we have are in one string, wo we have to split these names into given names and family name(s). That will probably cause some errors. e.g. "Albert Meron&#771;o Pen&#771;uela". Which are the given names and which is the family name?</li>
            <li>Try looking up 'Michael Kern' and you will get multiple returns. We can use the ORCID to look up all kinds of extra data for the persons we find, but for the scope of this project, we will probably only be able to use this procedure if we get exactly one hit, like we do for Ilaria Tiddi.</li>
        </ol>
    </p> 

    <p>We should probably set some rules for when to accept a result we get from the API as valid.</p>

    <p>You can play around with this using the form below. You might into an error, though. The script does not handle missing data very well yet... :-)</p>

    <!--- --->
    <cfoutput>

    <!--- --->
    <form action="" method="GET">
        <table class="mb-4">
            <tr>
                <td class="pr-2">Given names:</td>
                <td><input type="text" class="form-control" name="givennames" value="#url.givennames#" tabindex="1" placeholder="Enter the person's given names (e.g. Ilaria)"></td>
                <td class="pl-2"><input type="submit" class="btn btn-info" value="Enter" tabindex="3"></td>
            </tr>
            <tr>
                <td class="pr-2">Family name:</td>
                <td><input type="text" class="form-control" name="familyname" value="#url.familyname#" tabindex="2" placeholder="Enter the person's family name (e.g. Tiddi)"></td>
            </tr>
        </table>
    </form>

    <!--- --->
    <cfset sSearchURL = "https://pub.orcid.org/v3.0/search?q=family-name:#url.familyname#+AND+given-names:#url.givennames#">
    
    <!--- --->
    <cfhttp url="#sSearchURL#" method="get">
    <cffile action="write" file="#expandPath("tmp.xml")#" nameconflict="overwrite" output="#cfhttp.filecontent#">
    
    <!--- --->
    <cfset oXML = xmlParse("tmp.xml")>
 
    <!--- --->
    <cfset aResult = oXML["search:search"]["search:result"]>

    <h4>1. Search by given name and family name</h4>
    <p>using: #sSearchURL#</p>
 
    <cfif arrayLen(aResult) eq 0>
        <p class="alert alert-danger">No persons were found...</p>
    </cfif>

    <!--- --->
    <cfloop array="#aResult#" index="stResult">
        <!--- --->
        <div class="alert alert-info">
            <!--- --->
            <cfset sORCIDID = stResult["common:orcid-identifier"]["common:path"].XmlText>
        
            <!--- --->
            <cfset sInfoURL = "https://pub.orcid.org/v3.0/#sORCIDID#/person">
        
            <!--- --->
            <cfhttp url="#sInfoURL#" method="get">

            <!--- --->
            <cffile action="write" file="#expandPath("tmp.xml")#" nameconflict="overwrite" output="#cfhttp.filecontent#">

            <!--- --->
            <cfset oXML = xmlParse("tmp.xml")>
        
            <!--- --->
            <cfset sGivenNames = oXML.person.name["given-names"]>
            <cfset sFamilyName = oXML.person.name["family-name"]>

            <h4>2. Get info for a person that was found</h4>
            <p>using: #sInfoURL#</p>
            <hr>
            <p>Result:</p>

            #sORCIDID# = #sGivenNames# #sFamilyName#<br>
        </div>
    </cfloop>
    
    <!--- --->
    </cfoutput>
</div>
