// JavaScript Document
$(document).ready(function(){
	// Redirect to https if called over http
	if(window.location.hostname != 'localhost'){
		if(location.href.substring(0, 5) != 'https'){
			location.href = location.href.replace('http:', 'https:');
		};
	};

	// Date add function extension
	Date.prototype.addDays = function(days) {
		var date = new Date(this.valueOf());
		date.setDate(date.getDate() + days);
		return date;
	}
	
	// Set global date value and API-keys
	var dToday 		= new Date();
	sSpotifyAPIKey 	= '27d273b3d47f43a9ab51cda9ac1eea50';
	sSongKickAPIKey = 'gE5WDRAXXQaBr1xG';
	sMapBoxAPIKey	= 'pk.eyJ1IjoibWF0dGZpY2tlIiwiYSI6ImNqNnM2YmFoNzAwcTMzM214NTB1NHdwbnoifQ.Or19S7KmYPHW8YjRz82v6g&cachebuster=1581450881622';
	sGoogleMapsAPI	= 'AIzaSyAdXdGsTBen3jImU9XsSkc-LXRgE6FhzUo';

	// Init
	iDefaultPriceMin	= 0;
	iDefaultPriceMax	= 100;
	iDefaultLocationRadius		= 25;
	iDefaultLocationRadiusMin	= 5;
	iDefaultLocationRadiusMax	= 50;
	iDefaultDateMax				= 180;
	
	// map 
	oMapZoomSettings		= new Object();
	oMapZoomSettings[5] 	= 12;
	oMapZoomSettings[10] 	= 12;
	oMapZoomSettings[15] 	= 11;
	oMapZoomSettings[20] 	= 11;
	oMapZoomSettings[25] 	= 10;
	oMapZoomSettings[30] 	= 10;
	oMapZoomSettings[35] 	= 9;
	oMapZoomSettings[40] 	= 9;
	oMapZoomSettings[45] 	= 8;
	oMapZoomSettings[50] 	= 8;

	aRadius					= [10,25,50,100];

	// Set up the music facts array
	aMusicFacts = new Array;
	aMusicFacts.push('Musicians Have Shorter Life Spans Than the General Population');
	aMusicFacts.push('In 2016, Mozart Sold More CDs than Beyoncé');
	aMusicFacts.push('Singing in a Group Boosts Mood');
	aMusicFacts.push('Some People Feel Nothing Toward Music');
	aMusicFacts.push('Listening to Music Enhances Physical Performance');
	aMusicFacts.push('Rod Stewart Hosted the Largest Ever Free Concert');
	aMusicFacts.push('Wanna Be by The Spice Girls is the Catchiest Song of All Time');
	aMusicFacts.push('Finland Has the Most Metal Bands Per Capita');
	aMusicFacts.push('An Astronaut Released an Album with All Songs Recorded in Space');
	aMusicFacts.push('The British Navy Uses Britney Spears Songs to Scare Off Pirates');
	aMusicFacts.push('Jingle Bells Was Originally a Thanksgiving Song');
	aMusicFacts.push('Barry Manilow Didn\'t Write I Write the Songs');
	aMusicFacts.push('Music Affects Your Perception of the World');
	aMusicFacts.push('Music Helps Plants Grow Faster');
	aMusicFacts.push('None of The Beatles Could Read or Write Music');
	aMusicFacts.push('The Most Expensive Musical Instrument Sold for $15.9 Million');
	aMusicFacts.push('Metallica is the First and Only Band to Have Played on All 7 Continents');
	aMusicFacts.push('The Happy Birthday Song Brings A Bunch of Royalties');
	aMusicFacts.push('Musical Education Leads to Better Test Score');
	aMusicFacts.push('Listening to Music Utilizes the Entire Brain');
	aMusicFacts.push('Michael Jackson Tried to Buy Marvel Comics');
	aMusicFacts.push('The World\'s Longest Running Performance Will End in the 27th Century');
	aMusicFacts.push('Music is Physically Good for Your Heart');
	aMusicFacts.push('International Strange Music Day Is a Thing');
	aMusicFacts.push('A Sea Organ is Built Into the Coast of Croatia');
	aMusicFacts.push('Loud Music Causes You to Drink More in Less Time');
	aMusicFacts.push('A Song That Gets Stuck in Your Head is Called an Earworm');
	aMusicFacts.push('Cows Produce More Milk When Listening to Slow Music');
	aMusicFacts.push('Heavy Metal and Classical Music Fans Have Similar Personality Traits');
	aMusicFacts.push('Axl Rose Smoked Cigarettes As a Part-Time Gig');
	aMusicFacts.push('The Offspring\'s First Drummer Left the Band to Become a Gynecologist');
	aMusicFacts.push('Music Helps People with Brain Injuries Recall Personal Memories');
	aMusicFacts.push('Billie Holiday Was Billy Crystal\'s Babysitter');
	aMusicFacts.push('Monaco\'s Army is Smaller Than Its Military Orchestra');
	aMusicFacts.push('Prince Played 27 Instruments on His Debut Album');
	aMusicFacts.push('Born in the USA Isn\'t Pro-American');
	aMusicFacts.push('The Spice Girls Did Not Choose Their Nicknames');
	aMusicFacts.push('Janet Jackson\'s Super Bowl Wardrobe Malfunction Inspired the Idea for YouTube');
	aMusicFacts.push('Irreplaceable Was Written to be a Country Song');
	aMusicFacts.push('The Simpsons Do the Bartman Song Was Written by Michael Jackson');
	
	// console.log(aMusicFacts[getRandomInt(aMusicFacts.length)]);

	// Set up the page
	switchSpotifyAuthorisedOrNot();
	setupSearchPreferences();

	//// Event handlers

	// Event handler: set up the location search in the search panel
	$(document).on('click', '.startlocationsearch',		function(){
		$('#locationsearchdisplay').addClass('hidden');
		$('#locationsearchform').removeClass('hidden');
		$('.locationsearchviewtext').addClass('hidden');
		$('.locationsearchedittext').removeClass('hidden');
		$('#locationradiuscontrol').addClass('hidden');
		$('#locationsearch').focus();
	});
	// Event handler: Stop searching for locations in the search panel.
	$(document).on('click', '#cancellocationsearch',	function(){
		$('#locationsearchdisplay').removeClass('hidden');
		$('#locationsearchform').addClass('hidden');
		$('#locationradiuscontrol').removeClass('hidden');
		$('.locationsearchviewtext').removeClass('hidden');
		$('.locationsearchedittext').addClass('hidden');
		$('#locationsearchresult').html('');
		$('#locationsearch').val('');
	});	
	// Event handler: Call the MapBox API to search for locations.
	$(document).on('keyup', '#locationsearch',			function(){
		// Get the current search string from the form in the dialog.
		var sSearchString = $('#locationsearch').val();

		// Only search for places if the search string is larger than two characters long.
		if(sSearchString.length > 2){
			// MapBox Docs
			var sURL = 'https://api.mapbox.com/geocoding/v5/mapbox.places/' + sSearchString + '.json?access_token=' + sMapBoxAPIKey + '&cachebuster=1581450881622&autocomplete=true&types=place&limit=3';

			// Comments
			$.getJSON(sURL, function(oResponse) {
				// sButtons is the HTML for the buttons that render the search results.
				var sButtons = '';

				// Loop over the retrieved results and add a button for each result.
				$.each(oResponse.features, function(t, oItem) {
					// Turn the place name into an array, so it can be spliced.
					var aPlaceName = oItem.place_name.split(",");

					// Create the placename for the output, ommiting the second element.
					var sPlaceName = aPlaceName[0] + ', ' + aPlaceName[2];

					// Create a button in HTML
					sButtons = sButtons + '<div class="btn btn-info btn-block retrievedlocation" data-shortname="' 
						+ oItem.text
						+ '" data-fullname="' 
						+ sPlaceName 
						+ '" data-lat="' 
						+ oItem.center[1] 
						+ '" data-lon="' 
						+ oItem.center[0] 
						+ '">' 
						+ oItem.text	 
						+ '<br>' 
						+ '<small>' 
						+ aPlaceName[1]
						+ ', '
						+ aPlaceName[2]
						+ '</small>'
						+ '</div>';
				});

				// Insert the create buttons in the dialog.
				$('#locationsearchresult').html(sButtons);
			});
		}
		else{
			// Clear the search result buttons.
			$('#locationsearchresult').html('');
		};
		
	// Event handler: 
	});
	// Event handler: Store a location selected by the user in the location search.
	$(document).on('click', '.retrievedlocation',		function(){
		var sShortName	= $(this).data('shortname');
		var sFullName	= $(this).data('fullname');
		var fLat		= $(this).data('lat');
		var fLon		= $(this).data('lon');

		// Get the stored search panel parameters
		var oPanelSearchSettings = JSON.parse(localStorage.getItem('oPanelSearchSettings'));
		
		// Set the name and the coordinates for the chosen location
		oPanelSearchSettings['sLocationName']		= sShortName;
		oPanelSearchSettings['fLocationLat']		= fLat;
		oPanelSearchSettings['fLocationLng']		= fLon;		
		
		// Store the modified  search panel parameters
		localStorage.setItem('oPanelSearchSettings', JSON.stringify(oPanelSearchSettings));

		// Comments
		$('#searchpanellocationname').html(sShortName);
		$('.locationsearchviewtext').removeClass('hidden');
		$('.locationsearchedittext').addClass('hidden');
		$('#locationradiuscontrol').removeClass('hidden');
		$('#locationsearchresult').html('');
		$('#locationsearch').val('');
		
		// Comments
		renderSearchPanelLocationSection();
		detectChangeInSearchPanel();
	});
	// Event handler: Reset the seerch panel to its original settings
	$(document).on('click', '#resetsearchpanel',		function(){
		var sSpotifyToken = localStorage.sSpotifyToken;
		localStorage.clear();
		localStorage.sSpotifyToken = sSpotifyToken;
		setupSearchPreferences();
		renderSearchPanel();
	});
	// Event handler: Get recommendations initiated by the update button in the search panel.
	$(document).on('click', '.searchpanelupdatebutton',	function(){
		getConcerts();
	});
	// Event handler: Get recommendations initiated by the big button on the homepage.
	$(document).on('click', '.getrecommendationbutton',	function(){
		getConcerts();
	});
	// Event handler: play Spotify media for an artist
	$(document).on('click', '.playconcertmedia',		function(){
		var sSpotifyArtistID      = $(this).data('artistid');
		var sSpotifyArtistName    = $(this).data('artistname');
		playSpotifyPreview(sSpotifyArtistID, sSpotifyArtistName);
	});
	// Event handler: Show a pricavy consent modal before initating the sign in process
	$(document).on('click', '.signintospotify',			function(){
		modalPrivacyConsentForm()
	});
	// Event handler: Redirect the user to Spotify to get a token.
	$(document).on('click', '.gologin',        			function(){
		redirectToSpotifyForAuthentication();
	});
	// Event handler: Sign out of this application by clearing all user information from localStorage
	$(document).on('click', '.signoutofspotify',		function(){
		signOutOfSpotify()
	});
	// Event handler: Open a modal that embeds a Spotify tracklist for an artist that was listed as a reason for a concert list
	$(document).on('click', '.reasonband',				function(){
		var iSpotifyArtistID = $(this).data('artistid');
		renderModalArtistInfo(iSpotifyArtistID);
	});
	// Event handler: Switch from one concert mix to another concert mix.
	$(document).on('click', '.selectbin',				function(){
		var iBinID = $(this).data('binid');
		
		$('.selectbin').removeClass('btn-secondary').addClass('btn-outline-secondary');
		$(this).removeClass('btn-outline-secondary').addClass('btn-secondary').blur();
		
		$('.bin').hide();
		$('[data-binid=' + iBinID + ']').fadeIn();
	});
	// Event handler: Open the artist infomation modal
    $(document).on('click', '.artistpopup',				function(){
        var iArtistID           = $(this).data('artistid');
        var sArtistDescription  = $(this).data('artistdescription');
        var sArtistName         = $(this).data('name');
        
        modalArtistPopup(iArtistID, sArtistDescription, sArtistName);
	});
	// Event handler: Open the venue information modal
    $(document).on('click', '.venuepopup',				function(){
        var iSKVenueID           = $(this).data('skvenueid');
        modalVenuePopup(iSKVenueID);
	});
	// Event handler: go the home by reloading the page
    $(document).on('click', '.gohome',					function(){
        location.href = 'index.html';
	});
	// Event handler: reveal the services cards on the front page (authorized view)
    $(document).on('click', '#revealservices',			function(){
		$('#services').removeClass('hidden');
		$('#revealservices').addClass('hidden');
        $('#hideservices').removeClass('hidden');
	});
	// Event handler: hide the services cards on the front page (authorized view)
    $(document).on('click', '#hideservices',			function(){
        $('#services').addClass('hidden');
        $('#hideservices').addClass('hidden');
        $('#revealservices').removeClass('hidden');
	});
	// Event handler: Set radius form the button group in the search panel
    $(document).on('click', '.btnradius',			function(){
		var iNewRadius = $(this).data('radius');

		$('.btnradius').removeClass('btn-info').removeClass('disabled');
		$(this).addClass('btn-info').addClass('disabled');

		var oPanelSearchSettings = JSON.parse(localStorage.getItem('oPanelSearchSettings'));
		oPanelSearchSettings.iLocationRadius = iNewRadius;
		localStorage.setItem('oPanelSearchSettings', JSON.stringify(oPanelSearchSettings));

		detectChangeInSearchPanel();
	});	

    //// modalPrivacyConsentForm
    // Comments
    function modalPrivacyConsentForm(){
        // https://developer.spotify.com/documentation/general/guides/scopes/
        var sHTML = '';
        sHTML = sHTML + '<div class="modal" id="modalprivacyconsentform">';
        sHTML = sHTML + '	<div class="modal-dialog modal-dialog-centered modal-lg" role="document">';
        sHTML = sHTML + '		<div class="modal-content">';
        sHTML = sHTML + '			<div class="modal-header text-center pbx" id="modalprivacyconsentformheader">';
        sHTML = sHTML + '				<h4>Before we get going...</h4>';
        sHTML = sHTML + '			</div>';

        sHTML = sHTML + '			<div class="modal-body text-left" id="modalprivacyconsentformbody">';
        // sHTML = sHTML + '			<p>If you want to use gigscovery, you agree to share the following data for the duration of this session:</p>';
        sHTML = sHTML + '			    <p>Our service needs access to some of your personal information in Spotify to give you personalized concert recommendations. <strong>None</strong> of your personal information is stored on our servers.</p>';
        sHTML = sHTML + '			    <p>If you are comfortable with giving us access to your personal information, we would like you to log in to Spotify and grant us access to the following of your personal information in Spotify:</p>';
        
        sHTML = sHTML + '			    <div class="alert alert-warning">';
        sHTML = sHTML + '			    <ul>';
        sHTML = sHTML + '		 	       <li class="mb-2"><strong>Access to your top artists and tracks.</strong><br>We use your top artists and tracks to see what music your like listening to so we can recommend concerts to you.</li>';    // user-top-read
//        sHTML = sHTML + '		 	       <li class="mb-2"><strong>Access to your subscription details.</strong><br>Do we really need this?</li>';     // user-read-private
        sHTML = sHTML + '			    </ul>';     
        sHTML = sHTML + '			    </div>';     
        
        // sHTML = sHTML + '			<p>If you log out of gigscovery, all of your Spotify-related data will be removed immediately from our database.</p>';
        sHTML = sHTML + '			    <p>Are you sure you would like to use our service?</p>';
        
        sHTML = sHTML + '			</div>';

        sHTML = sHTML + '			<div class="modal-footer" id="modalprivacyconsentformfooter">';
        sHTML = sHTML + '				<button type="button" class="btn btn-outline-secondary" data-dismiss="modal">No, thanks</button>';
        sHTML = sHTML + '				<button type="button" class="btn btn-secondary gologin">Yes, go ahead</button>';
        sHTML = sHTML + '			</div>';

        sHTML = sHTML + '		</div>';
        sHTML = sHTML + '	</div>';
        sHTML = sHTML + '</div>';

        $('#modalprivacyconsentform').remove();
        $('#page').append(sHTML);
        $('#modalprivacyconsentform').modal();
        $('#modalprivacyconsentform').modal('show');        
    };
    
    //// modalVenuePopup(iSKVenueID);
    // Comments
    function modalVenuePopup(iSKVenueID){
        $.getJSON( 'https://api.songkick.com/api/3.0/venues/' + iSKVenueID + '.json?apikey=' + sSongKickAPIKey, {}).done(function(oResponse){
            var oVenue = oResponse.resultsPage.results.venue;
            
            if(oVenue.description === '')   {
                var sModalWidthclass = '';
                var sWidthCol1 = 'col-xl-7';
                var sWidthCol2 = 'col-xl-5';
                var sWidthCol3 = '';
            }
            else                            {
                var sModalWidthclass = 'modal-lg';
                var sWidthCol1 = 'col-xl-4';
                var sWidthCol2 = 'col-xl-3';
                var sWidthCol3 = 'col-xl-5';
            }
            
            var sHTML = '';
            sHTML = sHTML + '<div class="modal" id="modalvenueinfo">';
            sHTML = sHTML + '	<div class="modal-dialog modal-dialog-centered ' + sModalWidthclass + '" role="document">';
            sHTML = sHTML + '		<div class="modal-content">';
            sHTML = sHTML + '			<div class="modal-header text-center pbx" id="modalvenueinfoheader">';
            sHTML = sHTML + '				<h4>' + oVenue.displayName + '</h4>';
            sHTML = sHTML + '			</div>';
            
            sHTML = sHTML + '			<div class="modal-body text-center" id="modalvenueinfobody">';

            sHTML = sHTML + '			    <div class="row">';
            sHTML = sHTML + '			        <div class="' + sWidthCol1 + '">';
            sHTML = sHTML + '		                 <img class="card-img-top" id="venuelocationmap" src="https://maps.googleapis.com/maps/api/staticmap?center=' + oVenue.lat + ',' + oVenue.lng + '&zoom=15&size=400x400&maptype=roadmap&key=' + sGoogleMapsAPI + '" alt="">';
            sHTML = sHTML + '			        </div>';
            sHTML = sHTML + '			        <div class="' + sWidthCol2 + ' text-left">';
            sHTML = sHTML + '			            <p>';
            sHTML = sHTML + '                           <span class="bold">' + oVenue.displayName + '</span><br>';
            sHTML = sHTML +                             oVenue.street + '<br>';
            sHTML = sHTML +                             oVenue.zip + ' ' + oVenue.metroArea.displayName+ '<br>';
            sHTML = sHTML +                             oVenue.metroArea.displayName + '<br>';
			sHTML = sHTML +                             oVenue.metroArea.country.displayName + '<br>';
			if(oVenue.phone != null){
				sHTML = sHTML +                             oVenue.phone + '<br>';
			}
			if(oVenue.website != null){
				sHTML = sHTML + '                           <a href="' + oVenue.website + '" target="_blank" class="btn btn-sm btn-secondary mt-3">Website</a>';
			}
//            sHTML = sHTML +                             oVenue. + '<br>';
            sHTML = sHTML + '			            </p>';
            
            sHTML = sHTML + '			        </div>';
            sHTML = sHTML + '			        <div class="' + sWidthCol3 + ' text-left">' + oVenue.description;
            sHTML = sHTML + '			        </div>';
            sHTML = sHTML + '			    </div>';
            
            sHTML = sHTML + '			</div>';

            sHTML = sHTML + '			<div class="modal-footer" id="modalvenueinfofooter">';
            sHTML = sHTML + '				<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>';
            sHTML = sHTML + '			</div>';

            sHTML = sHTML + '		</div>';
            sHTML = sHTML + '	</div>';
            sHTML = sHTML + '</div>';

            $('#modalvenueinfo').remove();
            $('#page').append(sHTML);
            $('#modalvenueinfo').modal();
            $('#modalvenueinfo').modal('show');
        });
    };

    //// modalArtistPopup(iSpotifyArtistID, sArtistDescription, sArtistName);
    // Comments
    function modalArtistPopup(iSpotifyArtistID, sArtistDescription, sArtistName){      
        
		// Comments
		$.ajax(	{	url: 'https://api.spotify.com/v1/artists/' + iSpotifyArtistID,
					headers: {'Authorization': 'Bearer ' + localStorage.sSpotifyToken},
					  statusCode: {
						401: function() {

						}
					  }
				}).done(function(oArtistData) {
			
				if(sArtistDescription === '')	{var sModalSizeClass = ''}
				else							{var sModalSizeClass = 'modal-xl'}

                // Comments
                var sHTML = '';
                sHTML = sHTML + '<div class="modal" id="modalartistinfo">';
                sHTML = sHTML + '	<div class="modal-dialog ' + sModalSizeClass + ' modal-dialog-centered" role="document">';
                sHTML = sHTML + '		<div class="modal-content">';
                sHTML = sHTML + '			<div class="modal-header text-center pbx" id="modalartistinfoheader">';
                sHTML = sHTML + '				<h4>' + sArtistName + '</h4>';
                sHTML = sHTML + '			</div>';
                sHTML = sHTML + '			    <div class="row">';
                sHTML = sHTML + '			        <div class="col-xl-2">';
                sHTML = sHTML + '			            <img src="' + oArtistData.images[0].url + '" class="img-thumbnail mt-4 ml-3 mr-0 my-2">';
                sHTML = sHTML + '			        </div>';
                sHTML = sHTML + '			        <div class="col-xl-10 ">';
                sHTML = sHTML + '						<div class="modal-body" id="modalartistinfobody">' + sArtistDescription + '</div>';
                sHTML = sHTML + '			        </div>';
                sHTML = sHTML + '			    </div>';
                sHTML = sHTML + '			<div class="modal-footer" id="modalartistinfofooter">';
                sHTML = sHTML + '				<a href="https://open.spotify.com/artist/' + iSpotifyArtistID + '" target="_blank" class="btn btn-outline-secondary"><i class="fab fa-spotify"></i> Visit <strong>' + sArtistName + '</strong> on Spotify</a>';
                sHTML = sHTML + '				<div type="button" class="btn btn-secondary disabled" data-dismiss="modal">Close</div>';
                sHTML = sHTML + '			</div>';

                sHTML = sHTML + '		</div>';
                sHTML = sHTML + '	</div>';
                sHTML = sHTML + '</div>';

                $('#modalartistinfo').remove();
                $('#page').append(sHTML);
                $('#modalartistinfo').modal();
                $('#modalartistinfo').modal('show');
            
        });
    };
    
	//// renderModalArtistInfo(iSpotifyArtistID)
	// Comments
	function renderModalArtistInfo(iSpotifyArtistID){
		// Comments
		$.ajax(	{	url: 'https://api.spotify.com/v1/artists/' + iSpotifyArtistID,
					headers: {'Authorization': 'Bearer ' + localStorage.sSpotifyToken},
					  statusCode: {
						401: function() {

						},
						200: function() {

						}
					  }
				}).done(function(oArtistData) {
		});
		
	}

	//// signOutOfSpotify
	// Show an are-you-sure modal and if the user is sure, sign out by clearing localStorage
	function signOutOfSpotify(){
		// Create the HTML for the are=you-sure modal
		var sHTML = '';
		sHTML = sHTML + '<div class="modal" id="modalsignout">';
		sHTML = sHTML + '	<div class="modal-dialog modal-dialog-centered" role="document">';
		sHTML = sHTML + '		<div class="modal-content">';
		sHTML = sHTML + '			<div class="modal-header text-center pbx" id="modalsignoutheader">';
		sHTML = sHTML + '				<h4>gigscovery</h4>';
		sHTML = sHTML + '			</div>';
		sHTML = sHTML + '			<div class="modal-body" id="modalsignoutbody">Are you sure you want to sign out?</div>';
		
		sHTML = sHTML + '			<div class="modal-footer" id="modalsignoutfooter">';
		sHTML = sHTML + '				<button type="button" class="btn btn-secondary" data-dismiss="modal">No, thanks</button>';
		sHTML = sHTML + '				<div type="button" class="btn btn-info disabled" id="confirmsignout">Yes, sign me out</div>';
		sHTML = sHTML + '			</div>';
		
		sHTML = sHTML + '		</div>';
		sHTML = sHTML + '	</div>';
		sHTML = sHTML + '</div>';

		// Init the modal
		$('#modalsignout').remove();
		$('#page').append(sHTML);
		$('#modalsignout').modal();
		$('#modalsignout').modal('show');
		
		// Clear the user data that was stored in localStorage
		$('#confirmsignout').click(function(){
			$('#modalsignout').modal('hide');
			localStorage.clear();
			switchSpotifyAuthorisedOrNot();
		});
	};
	
	//// switchSpotifyAuthorisedOrNot
	// Comments
	function switchSpotifyAuthorisedOrNot(){
		// If the local storage has not property 'sSpotifyToken' yet, create it.
		if(localStorage.hasOwnProperty('sSpotifyToken') != true){
			localStorage.sSpotifyToken = '';
		}
		
		// See if the user has a token. If so, verify it is still valid. If not, redirect to Spotify auth.
		if(localStorage.sSpotifyToken === ''){
			// The user has no token, so redirect to Spotify for authentiction.
			buildScreenForNonAuthorisedUser();
		}
		else{
			var bTokenIsValid = verifySpotifyTokenIsStillValid();
			
			if(bTokenIsValid === true)	{
				buildScreenForAuthorisedUser();
			}
			else						{
											localStorage.sSpotifyToken = '';
											buildScreenForNonAuthorisedUser();
										}
		}
	}
	
	// redirectToSpotifyForAuthentication()
	// Comments
	function redirectToSpotifyForAuthentication(){
		// Comments
		var	sURL = 'https://accounts.spotify.com/authorize?';
		sURL = sURL + '&client_id=' + sSpotifyAPIKey;
		sURL = sURL + '&redirect_uri=https://www.scoaring.com/dscs/spotifyAuthRedirect.html';
		// sURL = sURL + '&scope=user-top-read%20user-read-private%20user-read-email';
        sURL = sURL + '&scope=user-top-read';
		sURL = sURL + '&response_type=token';
		sURL = sURL + '&state=123';

		// Comments		
		location.href = sURL;
	}
	
	// verifySpotifyTokenIsStillValid()
	// Comments
	function verifySpotifyTokenIsStillValid(){
		// Comments
		$.ajax(	{	url: 'https://api.spotify.com/v1/me',
					headers: {'Authorization': 'Bearer ' + localStorage.sSpotifyToken},
					  statusCode: {
						401: function() {
							localStorage.clear();
							location.href='index.html';
						},
						200: function() {
						}
					  }
				}).done(function(oUserData) {
		});
		return true;
	};

	//// buildScreenForAuthorisedUser()
    // Comments
	function buildScreenForAuthorisedUser(){
		// Comments
		$('.authorized').removeClass('hidden');
		$('.nonauthorized').addClass('hidden');

		// Comments
		$.ajax({
			url: 'https://api.spotify.com/v1/me',
			headers: {'Authorization': 'Bearer ' + localStorage.sSpotifyToken}
		}).done(function(oUserData) {
			// try catch toevoegen
			try {
				var sUserImgURL		= oUserData.images[0].url;
			}
			  catch(err) {
				var sUserImgURL		= '/dscs/images/generic-user.png';
			}

			
			// Comments
			var sHTML = '';
			sHTML = sHTML + '<div class="card mb-2">';
            sHTML = sHTML + '	<img class="card-img-top mb-0" src="/dscs/images/logo.png" alt="">';
			sHTML = sHTML + '	<div class="card-body text-center pt-0 pb-2 text-nonselectable">The Spotify powered concert discovery service</div>';
            sHTML = sHTML + '	<a href="' + oUserData.external_urls.spotify + '" target="_blank"><img class="card-img-top" src="' + sUserImgURL + '" alt=""></a>';
			sHTML = sHTML + '	<div class="card-body pt-0 pb-3">';
			sHTML = sHTML + '		<div class="card-body text-center pt-0 pb-1 text-nonselectable"><small>' + oUserData.display_name + '</small></div>';
			sHTML = sHTML + '		<div class="btn btn-secondary btn-block btn-sm signoutofspotify pointer text-nonselectable">Sign out</div>';
			sHTML = sHTML + '	</div>';
			sHTML = sHTML + '</div>';

			// Comments
			$('#headunit').html(sHTML);
			
			// Switch on the UI elements that are visible only to authorised users.
			renderSearchPanel();
			// getConcerts();
		});
		
//		$.getJSON('https://api.spotify.com/v1/me', 
//				   headers: {'Authorization': 'Bearer ' + localStorage.sSpotifyToken}).done(function(oUserData) {
// Comments
// sUserImgURL		= oUserData.images[0].url;
			
 }

	//// buildScreenForNonAuthorisedUser()
	// Comments
	function buildScreenForNonAuthorisedUser(){
		// Comments
		$('.authorized').addClass('hidden');
		$('.nonauthorized').removeClass('hidden');
		
		// Comments
		var sHTML = '';
		sHTML = sHTML + '<div class="card mb-2">';
		sHTML = sHTML + '	<img class="card-img-top" src="/dscs/images/logo.png" alt="">';
		// sHTML = sHTML + '     <div class="card-header bg-secondary text-white text-center pt-3 pb-2 gohome pointer">';
		// sHTML = sHTML + '         <i class="fas fa-share-alt fa-5x"></i>';
		// sHTML = sHTML + '         <h5 class="text-nonselectable"><strong>gigscovery</strong></h5>';
		// sHTML = sHTML + '     </div>';
		sHTML = sHTML + '     <div class="card-body pt-2 pb-2">';
		sHTML = sHTML + '         <p class="card-text text-center mt-0 text-nonselectable">The Spotify powered concert discovery service</p>';
		sHTML = sHTML + '         <div class="btn btn-warning btn-block btn-sm signintospotify pointer text-nonselectable bold">Sign in to Spotify now to get started</div>';
		sHTML = sHTML + '     </div>';
		sHTML = sHTML + '</div>';
		
		// Comments
		$('#headunit').html(sHTML);
	};

	//// renderAuthenticatedView
	// Comments
	function renderAuthenticatedView(){
		renderSearchPanel();
	};
	
	//// renderNonAuthenticatedView
	function renderNonAuthenticatedView(){};
	
	//// playSpotifyPreview
	// Comments
	function playSpotifyPreview(sSpotifyArtistID, sSpotifyArtistName){
		
		var sHTML = '';
		sHTML = sHTML + '<div class="modal" id="modalpreviewspotify" style="height:;">';
		sHTML = sHTML + '	<div class="modal-dialog modal-dialog-centered" role="document">';
		sHTML = sHTML + '		<div class="modal-content">';
		// sHTML = sHTML + '			<div class="modal-header pbx" id="modalpreviewspotifyheader">';
		// sHTML = sHTML + '				<h4 class="modal-title">Spotify Preview</h4>';
		// sHTML = sHTML + '			</div>';
		sHTML = sHTML + '			<div class="modal-body px-0 py-0" id="modalpreviewspotifybody">';
		sHTML = sHTML + '				<iframe id="spotifycontent" class="my-0" src="https://open.spotify.com/embed/artist/' + sSpotifyArtistID + '" width="100%" height="600" frameborder="0" allowtransparency="true" allow="encrypted-media"></iframe>';
		sHTML = sHTML + '			</div>';
		sHTML = sHTML + '			<div class="modal-footer" id="modalpreviewspotifyfooter">';
		sHTML = sHTML + '				<a href="https://open.spotify.com/artist/' + sSpotifyArtistID + '" target="_blank" class="btn btn-outline-secondary float-left"><i class="fab fa-spotify"></i> Visit <strong>' + sSpotifyArtistName + '</strong> on Spotify</a>';
		sHTML = sHTML + '				<div class="btn btn-secondary pointer" data-dismiss="modal">Close</div>';
		sHTML = sHTML + '			</div>';
		sHTML = sHTML + '		</div>';
		sHTML = sHTML + '	</div>';
		sHTML = sHTML + '</div>';

		$('#modalpreviewspotify').remove();
		$('#page').append(sHTML);
		$('#modalpreviewspotify').modal();
		$('#modalpreviewspotify').modal('show');
		
		// Comments
		// $('#spotifycontent').height($('#spotifycontent').contents().height());
		// $('#spotifycontent').height(($('#spotifycontent').contents().find('html').height()) + 'px')
		
		// var h = $('#spotifycontent').contents().height();
		// $('#spotifycontent').attr('height', h);
	};
	
	//// detectChangeInSearchPanel
	// Comments
	function detectChangeInSearchPanel(){
		// Comments
		var oCurrentSearchSettings	= JSON.parse(localStorage.getItem('oCurrentSearchSettings'));
		var oPanelSearchSettings	= JSON.parse(localStorage.getItem('oPanelSearchSettings'));

		// Comments
		var bIsDifferent = 0;

		// Was the location changed?
		if(oCurrentSearchSettings.fLocationLat != oPanelSearchSettings.fLocationLat || oCurrentSearchSettings.fLocationLng != oPanelSearchSettings.fLocationLng){bIsDifferent = 1};

		// Was the radius changed?
		if(oCurrentSearchSettings.iLocationRadius != oPanelSearchSettings.iLocationRadius){bIsDifferent = 1};

		// Were the start and end dates changed?
		if($.format.date(oCurrentSearchSettings.dStartDate, "d-MM-yyyy") != $.format.date(oPanelSearchSettings.dStartDate, "d-MM-yyyy")){
			bIsDifferent = 1;
		}

		if($.format.date(oCurrentSearchSettings.dEndDate, "d-MM-yyyy") != $.format.date(oPanelSearchSettings.dEndDate, "d-MM-yyyy")){
			bIsDifferent = 1;
		}

		// Compare the min and max prices
		// if(oCurrentSearchSettings.iPriceMin != oPanelSearchSettings.iPriceMin){bIsDifferent = 1};
		// if(oCurrentSearchSettings.iPriceMax != oPanelSearchSettings.iPriceMax){bIsDifferent = 1};
		
		// Compare the weekdays
		var oCurrentWeekDays	= JSON.parse(oCurrentSearchSettings.aDayOfWeek);
		var oPanelWeekDays		= JSON.parse(oPanelSearchSettings.aDayOfWeek);
		
		// Were weekdays selected or deselected?
		$.each(oCurrentWeekDays, function(sWeekDay, iState ) {
			var iCurrentState	= iState;
			var iPanelState		= oPanelWeekDays[sWeekDay];
			
			if(iCurrentState != iPanelState){bIsDifferent = 1};
		});

		// Comments
		if(bIsDifferent === 1){
			$('.getrecommendationbutton').removeClass('btn-info').addClass('btn-warning');
			$('.searchpanelupdatebutton').removeClass('hidden');
		}
		else{
			$('.getrecommendationbutton').addClass('btn-info').removeClass('btn-warning');
			$('.searchpanelupdatebutton').addClass('hidden');
		};
	};
	
	//// setupSearchPreferences
	// Set up a local storage for the search preferences used in the search bar
	function setupSearchPreferences(){
		// Set the initial search preferences, which are updated everytime a search is performed
		if(localStorage.hasOwnProperty('bSearchPreferencesCreated') != true){
			// Comments
			var aDayOfWeek = new Object();
			aDayOfWeek['su'] = 1;
			aDayOfWeek['mo'] = 1;
			aDayOfWeek['tu'] = 1;
			aDayOfWeek['we'] = 1;
			aDayOfWeek['th'] = 1;
			aDayOfWeek['fr'] = 1;
			aDayOfWeek['sa'] = 1;
		
			// oCurrentSearchSettings
			var oCurrentSearchSettings = new Object();
			oCurrentSearchSettings['sLocationName']		= 'Amsterdam';
			oCurrentSearchSettings['fLocationLat']		= 52.378;
			oCurrentSearchSettings['fLocationLng']		= 4.9;
			oCurrentSearchSettings['iLocationRadius']	= iDefaultLocationRadius;
			oCurrentSearchSettings['iPriceMin']			= iDefaultPriceMin;
			oCurrentSearchSettings['iPriceMax']			= iDefaultPriceMax;
			oCurrentSearchSettings['iDayOffsetFrom']	= 0;
			oCurrentSearchSettings['iDayOffsetTo']		= iDefaultDateMax;

			oCurrentSearchSettings['dStartDate']		= new Date();
			oCurrentSearchSettings['dEndDate']			= oCurrentSearchSettings['dStartDate'].addDays(iDefaultDateMax);

			oCurrentSearchSettings['aDayOfWeek']		= JSON.stringify(aDayOfWeek);
			localStorage.setItem('oCurrentSearchSettings', JSON.stringify(oCurrentSearchSettings));
			
			var oPanelSearchSettings = new Object();
			oPanelSearchSettings['sLocationName']		= oCurrentSearchSettings['sLocationName'];
			oPanelSearchSettings['fLocationLat']		= oCurrentSearchSettings['fLocationLat'];
			oPanelSearchSettings['fLocationLng']		= oCurrentSearchSettings['fLocationLng'];
			oPanelSearchSettings['iLocationRadius']		= oCurrentSearchSettings['iLocationRadius'];
			oPanelSearchSettings['iPriceMin']			= oCurrentSearchSettings['iPriceMin'];
			oPanelSearchSettings['iPriceMax']			= oCurrentSearchSettings['iPriceMax'];			
			oPanelSearchSettings['iDayOffsetFrom']		= oCurrentSearchSettings['iDayOffsetFrom'];
			oPanelSearchSettings['iDayOffsetTo']		= oCurrentSearchSettings['iDayOffsetTo'];
			
			oPanelSearchSettings['dStartDate']			= oCurrentSearchSettings['dStartDate'];
			oPanelSearchSettings['dEndDate']			= oCurrentSearchSettings['dEndDate'];

			oPanelSearchSettings['aDayOfWeek']			= oCurrentSearchSettings['aDayOfWeek'];
			localStorage.setItem('oPanelSearchSettings', JSON.stringify(oPanelSearchSettings));

			// Comments
			localStorage.setItem("bSearchPreferencesCreated",		true);
			localStorage.setItem("iMusicFactIndex",					true);
		};
	}
	
	//// renderSearchPanel
	// Render the search panel.
	function renderSearchPanel(){
		var oPanelSearchSettings = JSON.parse(localStorage.getItem('oPanelSearchSettings'));
		
		var sLocationName	= oPanelSearchSettings.sLocationName;
		var fLat 			= oPanelSearchSettings.fLocationLat;
		var fLng 			= oPanelSearchSettings.fLocationLng;
		var iLocationRadius = oPanelSearchSettings.iLocationRadius;
		var iPriceMin 		= oPanelSearchSettings.iPriceMin;
		var iPriceMax 		= oPanelSearchSettings.iPriceMax;
		var iDayOffsetFrom	= oPanelSearchSettings.iDayOffsetFrom;
		var iDayOffsetTo	= oPanelSearchSettings.iDayOffsetTo;

		var sHTML = '';
		sHTML = sHTML + '<div class="card">';
		sHTML = sHTML + '	<ul class="list-group list-group-flush">';
		sHTML = sHTML + '		<img class="card-img-top" id="locationmap" src="https://maps.googleapis.com/maps/api/staticmap?center=' + fLat + ',' + fLng + '&zoom=11&size=400x400&maptype=roadmap&key=' + sGoogleMapsAPI + '" alt="">';
		sHTML = sHTML + '		<li class="list-group-item">';
		sHTML = sHTML + '			<div class="row">';
// 		sHTML = sHTML + '				<div class="col-xl-12 pl-2 text-muted center locationsearchviewtext mb-2 text-nonselectable"><small>Look for concerts within <span class="radiusslidercurrent bold">' + iLocationRadius + ' km</span> of:</small></div>';
 		sHTML = sHTML + '				<div class="col-xl-12 pl-2 text-muted center locationsearchviewtext mb-2 text-nonselectable">Look for concerts in:</div>';
		sHTML = sHTML + '			</div>';
		
		// Comments
		sHTML = sHTML + '			<div class="row" id="locationsearchdisplay">';
		sHTML = sHTML + '				<div class="col-xl-12 pl-2 text-muted center mb-0">';
		sHTML = sHTML + '					<div class="btn btn-info btn-sdm btn-block pointer startlocationsearch" id="searchpanellocationname"></div>';
		sHTML = sHTML + '				</div>';
		sHTML = sHTML + '			</div>';
		
		// Comments
		sHTML = sHTML + '			<div id="locationsearchform" class="hidden">';
		sHTML = sHTML + '				<div class="row">';
		sHTML = sHTML + '					<div class="col-xl-9">';
		sHTML = sHTML + '						<input type="text" class="form-control mb-3" id="locationsearch" style="font-size:0.8em;" placeholder="Type your location here...">';
		sHTML = sHTML + '					</div>';
		sHTML = sHTML + '					<div class="col-xl-3">';
		sHTML = sHTML + '						<div class="btn btn-sm btn-info pointer float-right" id="cancellocationsearch">Cancel</div>';
		sHTML = sHTML + '					</div>';
		sHTML = sHTML + '				</div>';
		sHTML = sHTML + '				<div id="locationsearchresult"></div>';
		sHTML = sHTML + '			</div>';
		sHTML = sHTML + '		</li>';

		// Comments
		sHTML = sHTML + '		<li class="list-group-item" id="">';
		 sHTML = sHTML + '			<div class="row">';
 		sHTML = sHTML + '				<div class="col-xl-12 pl-2 text-muted center locationsearchviewtext mb-2 text-nonselectable">Radius (km):</div>';
		sHTML = sHTML + '				<div class="col-xl-12 text-center">';
		sHTML = sHTML + '					<div class="btn-group btn-group-justified">';

		// Render the button group		
		$.each(aRadius, function( index, iRadiusValue ) {
			if(parseInt(iRadiusValue) === oPanelSearchSettings.iLocationRadius)	{var sBtnClass = 'btn-info disabled';}
			else														{var sBtnClass = 'btn-default';}
			sHTML = sHTML + '						<div class="btn-group">';
			sHTML = sHTML + '		  					<button type="button" class="btn ' + sBtnClass + ' border btnradius" data-radius="' + iRadiusValue + '">' + iRadiusValue + '</button>';
			sHTML = sHTML + '						</div>';
		});

		sHTML = sHTML + '					</div>';
		sHTML = sHTML + '				</div>';		
		sHTML = sHTML + '			</div>';		
		sHTML = sHTML + '		</li>';

        // Comments <input id="date-input" type="text">
		sHTML = sHTML + '		<li class="list-group-item" id="searchControlDate">';
		sHTML = sHTML + '			<div class="row">';
 		sHTML = sHTML + '				<div class="col-xl-12 pl-2 text-muted center locationsearchviewtext mb-2 text-nonselectable">During this period:</div>';
		sHTML = sHTML + '			</div>';
		sHTML = sHTML + '			<div class="row">';
		sHTML = sHTML + '				<div class="col-xl-3 px-1 pt-2">From:</div>';
		sHTML = sHTML + '				<div class="col-xl-9 px-1" id="datefromcontainer"><input id="startdate"></div>';
		sHTML = sHTML + '			</div>';
		sHTML = sHTML + '			<div class="row pt-2">';
		sHTML = sHTML + '				<div class="col-xl-3 px-1 pt-2">Till:</div>';
		sHTML = sHTML + '				<div class="col-xl-9 px-1" id="datetillcontainer"><input id="enddate"></div>';
		sHTML = sHTML + '			</div>';
		sHTML = sHTML + '		</li>';
	
		// Comments
		// sHTML = sHTML + '		<li class="list-group-item" id="searchControlWeekdays">';
		// sHTML = sHTML + '			<div class="row">';
		// sHTML = sHTML + '				<div class="col-xl-12 pl-2 text-muted center mb-2 text-nonselectable">Which days of the week are you available?</div>';
		// sHTML = sHTML + '			</div>';
		// sHTML = sHTML + '			<div class="btn-group btn-group-sm d-flex" role="group" id="weekdaybuttongroup">';
		// sHTML = sHTML + '			</div>';		
		// sHTML = sHTML + '		</li>';

		// Comments
		sHTML = sHTML + '	</ul>';
		sHTML = sHTML + '</div>';
		
		sHTML = sHTML + '<div class="btn btn-block btn-warning mt-3 mb-2 pointer searchpanelupdatebutton hidden" id="">Update your concert list</div>';
		
		sHTML = sHTML + '<div class="center">';
		sHTML = sHTML + '	<div class="btn btn-sm mx-5 mt-2 btn-outline-light border text-black-50 pointer" id="resetsearchpanel">Reset search preferences</div>';
		sHTML = sHTML + '<div>';
		
		$('#searchpanel').html(sHTML);
		
		// Init the price slider
		$("#priceslider").slider({tooltip: 'always'});
		$("#radiusslider").slider({tooltip: 'always'});

		// Get the current search settings
		var dToday = new Date();
        var oSearchSettings	= JSON.parse(localStorage.getItem('oPanelSearchSettings'));
		var d = oSearchSettings.dStartDate;
		var sDateTill = oSearchSettings.dEndDate;

		// $.format.date(dToday.addDays(oSearchSettings.iDayOffsetFrom), "yyyy-MM-dd");
		var sStartDate	= $.format.date(oSearchSettings.dStartDate, "d-MM-yyyy");
		var sEndDate 	= $.format.date(oSearchSettings.dEndDate, "d-MM-yyyy");

        $('#startdate').datepicker({
            uiLibrary: 'bootstrap4',
            iconsLibrary: 'fontawesome',
			minDate: dToday,
			format: 'dd-mm-yyyy',
			value: sStartDate,
            maxDate: function () {
                return $('#enddate').val();
            },
			change: 		function(e) {
				handleDatePickerChange(e);
			}
        });
        $('#enddate').datepicker({
            uiLibrary: 'bootstrap4',
            iconsLibrary: 'fontawesome',
			format: 'dd-mm-yyyy',
			value: sEndDate,
            minDate: function () {
                return $('#startdate').val();
			},
			change: 		function(e) {
				handleDatePickerChange(e);
			}
		});
		
		// handleDatePickerChange
		function handleDatePickerChange(e){
			// Comments
			var sDate		= e.delegateTarget.value;
			var sID			= e.delegateTarget.id;
			var aDateParts	= sDate.split('-');

			// Comments
			var dNewDate = new Date(aDateParts[2], parseInt(aDateParts[1]-1), aDateParts[0], 10,0,0);
			var oPanelSearchSettings = JSON.parse(localStorage.getItem('oPanelSearchSettings'));
			if(sID === 'startdate'){
				oPanelSearchSettings.dStartDate = dNewDate;
			}
			else{
				oPanelSearchSettings.dEndDate = dNewDate;
			};
			localStorage.setItem('oPanelSearchSettings', JSON.stringify(oPanelSearchSettings));
			
			// Comments
			detectChangeInSearchPanel();
		}

		// Comments
		renderWeekDayButtonGroup();
		
		// Comments
		renderSearchPanelLocationSection();

		// Comments
		// var e = $('#priceslider').slider().on('change', updateSliderBounds).data('slider');
		// var f = $('#radiusslider').slider().on('change', updateRadiusSlider).data('slider');
		// var g = $('#dateslider').slider().on('change', updateDateSlider).data('slider');
		
		// Comments
		function handleSliderChange(e){updateSliderBounds()};

		// Comments
		function updateDateSlider(e){
			var aDateSliderValues = $("#dateslider").slider("getValue");
			$('.radiusslidercurrent').html(iLocationRadius + ' km');
			
			var oPanelSearchSettings = JSON.parse(localStorage.getItem('oPanelSearchSettings'));
			oPanelSearchSettings.iDayOffsetFrom = aDateSliderValues[0];
			oPanelSearchSettings.iDayOffsetTo	= aDateSliderValues[1];
			localStorage.setItem('oPanelSearchSettings', JSON.stringify(oPanelSearchSettings));

			$('#daterangefrom').html(aDateSliderValues[0]);
			$('#daterangeto').html(aDateSliderValues[1]);
            
			// Comments
			if(aDateSliderValues[0] == '0'){
				$('#daterangefrom').html('Today');
			}
			else{
				$('#daterangefrom').html(formatDate((dToday.addDays(aDateSliderValues[0]))));
			};

			// Comments
			if(aDateSliderValues[1] == '0'){
				$('#daterangeto').html('Today');
			}
			else{
				$('#daterangeto').html(formatDate((dToday.addDays(aDateSliderValues[1]))));
			};
			
			// Comments
			detectChangeInSearchPanel();
		};
		
		// Comments
		function updateRadiusSlider(e){
			var iLocationRadius = $("#radiusslider").slider("getValue");
			$('.radiusslidercurrent').html(iLocationRadius + ' km');
			var oPanelSearchSettings = JSON.parse(localStorage.getItem('oPanelSearchSettings'));
			oPanelSearchSettings.iLocationRadius = iLocationRadius;
			localStorage.setItem('oPanelSearchSettings', JSON.stringify(oPanelSearchSettings));
			
			renderSearchLocationMap();
			detectChangeInSearchPanel();
		};
		
		// Comments
		function updateSliderBounds(){

			// var aPriceRange = $("#priceslider").slider("getValue");
			
			// Store the new values of the slider in the local storage
			var oPanelSearchSettings = JSON.parse(localStorage.getItem('oPanelSearchSettings'));
			oPanelSearchSettings.iPriceMin = aPriceRange[0];
			oPanelSearchSettings.iPriceMax = aPriceRange[1];
			localStorage.setItem('oPanelSearchSettings', JSON.stringify(oPanelSearchSettings));

			// Comments
			if(aPriceRange[0] == '0'){
				$('#slidercurrentmin').html('Free!');
			}
			else{
				$('#slidercurrentmin').html('&euro; ' + aPriceRange[0]);
			};

			// Comments
			if(aPriceRange[1] == '100'){
				$('#slidercurrentmax').html('&euro; ' + aPriceRange[1] + '+');
			}
			else if(aPriceRange[1] == '0'){
				$('#slidercurrentmax').html('');
			}
			else{
				$('#slidercurrentmax').html('&euro; ' + aPriceRange[1]);
			};
			
			detectChangeInSearchPanel();
		};
	}

	//// renderSearchLocationMap
	// Comments
	function renderSearchLocationMap(){
		// Comments
		var oPanelSearchSettings = JSON.parse(localStorage.getItem('oPanelSearchSettings'));

		// Comments
		var fLat 	= oPanelSearchSettings.fLocationLat;
		var fLng	= oPanelSearchSettings.fLocationLng;
		var iZoom	= oMapZoomSettings[oPanelSearchSettings.iLocationRadius];
		
		// Comments
		var sMapURL		= 'https://maps.googleapis.com/maps/api/staticmap?center=' + fLat + ',' + fLng + '&zoom=13&size=400x250&maptype=roadmap&key=' + sGoogleMapsAPI;
		
		// Comments
		$('#locationmap').attr('src', sMapURL);
	};
	
	//// renderSearchPanelLocationSection
	// Comments
	function renderSearchPanelLocationSection(){
		var oPanelSearchSettings = JSON.parse(localStorage.getItem('oPanelSearchSettings'));
		var fLat 			= oPanelSearchSettings.fLocationLat;
		var fLng 			= oPanelSearchSettings.fLocationLng;
		var sLocationName	= oPanelSearchSettings.sLocationName;
		
		renderSearchLocationMap();
		$('#searchpanellocationname').html(sLocationName);
		
		$('#locationsearchdisplay').removeClass('hidden');
		$('#locationsearchform').addClass('hidden');
	};
	
	//// renderWeekDayButtonGroup
	// Comments
	function renderWeekDayButtonGroup(){

		// Comments
		var sHTML = '';	
		sHTML = sHTML + '				<button type="button" class="btn btn-light border dayofweek" data-day="su">Su</button>';
		sHTML = sHTML + '				<button type="button" class="btn btn-light border dayofweek" data-day="mo">Mo</button>';
		sHTML = sHTML + '				<button type="button" class="btn btn-light border dayofweek" data-day="tu">Tu</button>';
		sHTML = sHTML + '				<button type="button" class="btn btn-light border dayofweek" data-day="we">We</button>';
		sHTML = sHTML + '				<button type="button" class="btn btn-light border dayofweek" data-day="th">Th</button>';
		sHTML = sHTML + '				<button type="button" class="btn btn-light border dayofweek" data-day="fr">Fr</button>';
		sHTML = sHTML + '				<button type="button" class="btn btn-light border dayofweek" data-day="sa">Sa</button>';
		$('#weekdaybuttongroup').html(sHTML);

		// Comments
		var oPanelSearchSettings = JSON.parse(localStorage.getItem('oPanelSearchSettings'));
		
		var aDayOfWeek = JSON.parse(oPanelSearchSettings.aDayOfWeek);

		$.each(aDayOfWeek, function(sWeekDay, iState ) {
			if(iState === 1){
				$(".dayofweek[data-day='" + sWeekDay + "']").removeClass('btn-light').addClass('btn-info');
			}
			else{
				// $(".dayofweek[data-day='" + sWeekDay + "']").removeClass('btn-light').addClass('btn-success');
			};
		});
	};
	
	//// formatDate(dDate)
	// Comments
	function formatDate(dDate){
		var oMonths = new Object;
		oMonths[0]	= 'Jan';
		oMonths[1]	= 'Feb';
		oMonths[2]	= 'Mar';
		oMonths[3]	= 'Apr';
		oMonths[4]	= 'May';
		oMonths[5]	= 'Jun';
		oMonths[6]	= 'Jul';
		oMonths[7]	= 'Aug';
		oMonths[8]	= 'Sep';
		oMonths[9] = 'Oct';
		oMonths[10] = 'Nov';
		oMonths[11] = 'Dec';
		
		return oMonths[dDate.getMonth()] + ' ' + dDate.getDate();
	};

	//// getConcerts
	// Comments
	function getConcerts(){
		// Get the current search settings and do not parse the JSON, so it can be sent as is to the server.'
        var oSearchSettings	= JSON.parse(localStorage.getItem('oPanelSearchSettings'));

		// Comments
        var dToday = new Date();
        
		// Comments
        var oQueryString = new Object();
        oQueryString['locationname']    = oSearchSettings.sLocationName;
        oQueryString['lat']             = oSearchSettings.fLocationLat;
        oQueryString['lng']             = oSearchSettings.fLocationLng;
        oQueryString['startdate']       = $.format.date(oSearchSettings.dStartDate, "yyyy-MM-dd");
		oQueryString['enddate']         = $.format.date(oSearchSettings.dEndDate, "yyyy-MM-dd");
		oQueryString['iLocationRadius'] = oSearchSettings.iLocationRadius;
        
        // Comments
        var aDayOfWeek = JSON.parse(oSearchSettings.aDayOfWeek);
        $.each(aDayOfWeek, function(sDayOfWeek, bSelected) {
            oQueryString[sDayOfWeek]    = bSelected;
        });

		// Construct the URL that will be called to get the bins
		var sURL = 'https://178.62.203.147:8000/get_bins?';
		sURL = sURL + 'latitude='			+ oSearchSettings.fLocationLat + '&';
		sURL = sURL + 'longitude='			+ oSearchSettings.fLocationLng + '&';
		sURL = sURL + 'date_begin='			+ $.format.date(oSearchSettings.dStartDate, "yyyy-MM-dd") + '&';
		sURL = sURL + 'date_end='			+ $.format.date(oSearchSettings.dEndDate, "yyyy-MM-dd") + '&';
		sURL = sURL + 'token='				+ localStorage.sSpotifyToken + '&';
		sURL = sURL + 'radius='				+ oSearchSettings.iLocationRadius + '&';
		sURL = sURL + 'top_artists='		+ 5 + '&';
		sURL = sURL + 'related_artists='	+ 5;

        // Construct the test version of the URL
        var sQueryString = '';
        var x = 1;
        $.each(oQueryString, function(name, value) {
            sQueryString = sQueryString + '&' + name + '=' + value;
        });
		// sURL = 'dummy/dummyGetConcerts.cfm?r=' + Math.round(Math.random() * 10) + sQueryString, {}
        // Construct the test version of the URL

		// Show the full screen wait loader lightbox.
		show();

		// Comments
		$.getJSON( sURL, {}).done(function(oJSON){
			// Comments
			var sHTML = '';
			
			// Sometimes the endpoints return a valid response with zero concerts. Use bThereIsSomethingToShow during the subsequent loops
			// to indicate whether there actually was at least one concert. IF bThereIsSomethingToShow = false after all the loops, show
			// a message so the screen does not end up empty.
			var bThereIsSomethingToShow = false;

			// Add a breadcrumb trail
			sHTML = sHTML + '<nav aria-label="breadcrumb">';
			sHTML = sHTML + '	<ol class="breadcrumb">';
			sHTML = sHTML + '		<li class="breadcrumb-item"><a href="index.html">Home</a></li>';
			sHTML = sHTML + '		<li class="breadcrumb-item active" aria-current="page">Concerts</li>';
			sHTML = sHTML + '	</ol>';
			sHTML = sHTML + '</nav>';

			// Create the bins button group
			sHTML = sHTML + '<div class="btn-group btn-group-justified" role="group" aria-label="">';
			
			// Add the bins
			$.each(oJSON.user_bins, function(t, oBin) {
				sHTML = sHTML + '<div class="btn-group">';
  				sHTML = sHTML + '	<button type="button" class="btn btn-outline-secondary selectbin" data-binid="' + oBin.id + '">Concert Mix ' + parseInt(oBin.id + 1) + '</button>';
				sHTML = sHTML + '</div>';
			});
			
			// Comments
			sHTML = sHTML + '</div>';
			
			// Loop over the bins in the response and create a bin in the DOM for every bin entry
			$.each(oJSON.user_bins, function(t, oBin) {
				var aTopArtists		= new Array;
				var aRelatedArtists	= new Array;

				// Populate aTopArtists
				$.each(oBin.bin_reason, function(t, oReason) {
					if(oReason.band_flag === 'top'){
						aTopArtists.push(oReason);
					}
				});
				// Populate aRelatedArtists
				$.each(oBin.bin_reason, function(t, oReason) {
					if(oReason.band_flag === 'related'){
						aRelatedArtists.push(oReason);
					}
				});

				// List the bands that were used to arrive at the contents of this bin.
				sHTML = sHTML + '<div class="bin" style="display:none;" data-binid="' + oBin.id + '">';
				sHTML = sHTML + '	<div class="">';
				sHTML = sHTML + '		<p>We recommend the following concerts because you listened to ';

				// List the top artists
				$.each(aTopArtists, function(t, oReason) {
					if(oReason.band_flag === 'top'){
						sHTML = sHTML + '	<a class="bold" href="https://open.spotify.com/artist/' + oReason.band_spotify_id  + '" data-toggle="hover" title="" data-placement="top" data-content="Click to see more of ' + oReason.band_name  + '." target="_blank" class="" data-artistid="' + oReason.band_spotify_id  + '">' + oReason.band_name  + '</a>';
						
						if(parseInt(t+2) === aTopArtists.length){
							sHTML = sHTML + ' and ';	
						}
						else{
							sHTML = sHTML + ' ';	
						}
					}
				});

				sHTML = sHTML + '	and because you might like to listen to ';
				console.log(aRelatedArtists);
				// List the related artists
				$.each(aRelatedArtists, function(t, oReason) {
					if(oReason.band_flag === 'related'){
						sHTML = sHTML + '	<a href="https://open.spotify.com/artist/' + oReason.band_spotify_id  + '" data-toggle="hover" title="" data-placement="top" data-content="Click to see more of ' + oReason.band_name  + '." target="_blank" class="" data-artistid="' + oReason.band_spotify_id  + '">' + oReason.band_name  + '</a>';
						
						console.log(parseInt(t+1) + ' - ' + aRelatedArtists.length);
						if(parseInt(t+2) === aRelatedArtists.length){
							sHTML = sHTML + ' and';	
						}
						else if (parseInt(t+1) === aRelatedArtists.length){
							sHTML = sHTML + '.';	
						}
						else{
							sHTML = sHTML + ',';	
						}
					}
				});

				sHTML = sHTML + '</p></div>';
				
				// List the concerts in this bin.
				sHTML = sHTML + '	<div class="row">';
				$.each(oBin.concerts, function(t, oConcert) {
					// Comments
					if(oConcert.length != 0){

						// Concert Card
						sHTML = sHTML + '		<div class="col-xl-4 concertcard" data-artistid="' + oConcert[0].artist_id + '" data-artistdescription="' + oConcert[0].description + '">';
						sHTML = sHTML + '			<div class="card mb-2">';
						sHTML = sHTML + '				<div class="overlaycontainer playconcertmedia artist mx-0" data-artistname="' + oConcert[0].name + '" data-artistid="' + oConcert[0].spotify_id + '">';
						sHTML = sHTML + '					<img class="card-img-top image" style="display: block;" src="' + oConcert[0].photo + '" alt="">';
						sHTML = sHTML + '					<div class="overlay pointer"><i class="fas fa-play-circle fa-4x"></i></div>';
						sHTML = sHTML + '				</div>';
						sHTML = sHTML + '				<div class="card-body">';
						sHTML = sHTML + '					 <h5 class="card-title mb-0 pl-0 cardartist artist" data-artistid="' + oConcert[0].artist_id + '">' + oConcert[0].name + '</h5>';
						sHTML = sHTML + '					 <p class="card-text mb-2">';
						sHTML = sHTML + '					     <small><span class="venuename" data-venuename="' + oConcert[0].venue.name + '">' + oConcert[0].venue.name + '</span></small><br>';
						sHTML = sHTML + '					     <small>' + oConcert[0].venue.city + '</small><br/>';
						sHTML = sHTML + '					     <small>' + $.format.date(oConcert[0].date, "dd-MM-yyyy") + ' ' + $.format.date(oConcert[0].date, "HH:mm") + '</small>';
						sHTML = sHTML + '					 </p>';
						
						if(oConcert.description != '') {
							sHTML = sHTML + '                   <i class="fas fa-info-circle fa-2x float-right artist artistpopup pointer" data-name="' + oConcert[0].name + '" data-artistid="' + oConcert[0].spotify_id + '" data-artistdescription="' + oConcert[0].description + '"></i>';
						}
						
					// Comments
					// TODO Insert a loop here in case one artist has more than one concert. 
					$.each(oConcert[0].offers, function(t, oOffer) {
						// Indicate that there was (at least one) concert, so we don't have to show a message saying that no concerts were found.
						bThereIsSomethingToShow = true;
						
						// Comments
						if(oOffer.type === 'Tickets'){}
							sHTML = sHTML + '					<a href="' + oOffer.url + '" target="_blank" class="btn btn-outline-success btn-sm">' + oOffer.type + '</a>';
					});
						sHTML = sHTML + '				</div>';
						sHTML = sHTML + '			</div>';
						sHTML = sHTML + '		</div>';

					// End of Concert Card
				};
			});
				sHTML = sHTML + '	</div>';
				sHTML = sHTML + '</div>';
			});
			
			// Comments
			sHTML = sHTML + '</div>';

			// Hide the full screen wait loader lightbox.
			hide();

			// If no concerts were returned, show a message that says so.
			if(bThereIsSomethingToShow === false){
				// Get the search settings from localStorage
				var oPanelSearchSettings = JSON.parse(localStorage.getItem('oPanelSearchSettings'));				

				// Render a message
				sHTML = sHTML + '<div class="text-center">';
				sHTML = sHTML + '	<i class="far fa-sad-tear fa-10x text-black-50 mb-3"></i>';
				sHTML = sHTML + '	<p class="text-black-50" style="font-size:1.5em;">It looks like no concerts were found for you within <strong>' + oPanelSearchSettings.iLocationRadius + '</strong> kilometers of <strong>' + oPanelSearchSettings.sLocationName + '</strong> during the period<br>from <strong>' + $.format.date(oPanelSearchSettings.dStartDate, "d-MM-yyyy") + '</strong> to <strong>' + $.format.date(oPanelSearchSettings.dEndDate, "d-MM-yyyy") + '</strong>...</p>';
				sHTML = sHTML + '	<a href="index.html" class="btn btn-secondary">Go back</a>';
				sHTML = sHTML + '</div>';

			};

			// Comments
			$('#results').html(sHTML);
			
			$("[data-binid=0]").fadeIn();
			$(".selectbin[data-binid=0]").removeClass('btn-outline-secondary').addClass('btn-secondary');
            $('[data-toggle="hover"]').popover({ trigger: "hover" });
			
			$('.searchpanelupdatebutton').addClass('hidden');
            getVenueFromSongKick();
        });
	}

//	function insertArtistSpotifyIDs(){
//		$.ajax(	{	url: 'https://api.spotify.com/v1/search?q=slayer&type=artist',
//		headers: {'Authorization': 'Bearer ' + localStorage.sSpotifyToken}
//		}).done(function(oData) {
//			console.log(oData.artists.items[0].id);
//		});
//	
//	};	

	//// getSpotifyUserData
	// Comments
	function getSpotifyUserData() {
		
		return $.ajax({
			url: 'https://api.spotify.com/v1/me',
			headers: {
			   'Authorization': 'Bearer ' + localStorage.sSpotifyToken
			}
		});
	}	
	
    // getVenueFromSongKick
    function getVenueFromSongKick(){ 
        // 
        var aVenues = [];
        
        // Create an array of unique venue that are currently being displayed.
        $('.venuename').each(function( index ) {
            // Comments
            var sThisVenueName = $(this).text();
            
            // Comments
            if(aVenues.indexOf(sThisVenueName) === -1){
                aVenues.push(sThisVenueName);   
            };
        });        
        
		// Comments
        $.each(aVenues, function(x, sVenueName) {
			// Comments

            $.getJSON( 'https://api.songkick.com/api/3.0/search/venues.json?query=' + sVenueName + '&apikey=' + sSongKickAPIKey, {}).done(function(oResponse){
				if(oResponse.resultsPage.totalEntries > 0){
					var oVenue = oResponse.resultsPage.results.venue[0];
					$('[data-venuename="' + sVenueName + '"]').html('<span class="venuepopup pointer bold" data-skvenueid="' + oVenue.id + '">' + oVenue.displayName + '</span>');
				}
            });
        });
    };
    
    // Video light box
    $(".js-video-button").modalVideo({
        youtube:{
            autoplay:1,
            controls:0,
            nocookie: true
        }
    });
    
    // Every minute, verify that the Spotify token is still valid. If not, force sign out.
    setInterval(function() {
          verifySpotifyTokenIsStillValid();
	}, 60000);
	
});

//// getRandomInt
function getRandomInt(max) {
	return Math.floor(Math.random() * Math.floor(max));
	}	

function show(){
	$('.excuse').hide();
	document.getElementById("spinner-front").classList.add("show");
	document.getElementById("spinner-back").classList.add("show");
  
	var sRandomMusicFact = aMusicFacts[getRandomInt(aMusicFacts.length)];
	console.log(sRandomMusicFact);
	$('#musicfact').html(aMusicFacts[getRandomInt(aMusicFacts.length)]);
  
  //  to1 = setTimeout(function(){showExcuseMessage('excuse01')},  5000);
  //  to2 = setTimeout(function(){showExcuseMessage('excuse02')}, 10000);
  //  to3 = setTimeout(function(){showExcuseMessage('excuse03')}, 15000);
  //  to4 = setTimeout(function(){showExcuseMessage('excuse04')}, 20000);
  //  to5 = setTimeout(function(){showExcuseMessage('excuse05')}, 25000);
  }
  
  function hide(){
	document.getElementById("spinner-front").classList.remove("show");
	document.getElementById("spinner-back").classList.remove("show");
  //  $('.excuse').hide();
  
  //  clearTimeout(to1);
  //  clearTimeout(to2);
  //  clearTimeout(to3);
  //  clearTimeout(to4);
  //  clearTimeout(to5);
  }
  
  // Comments
  function showExcuseMessage(iMessageID){
	$('.excuse').hide();
	$('#' + iMessageID).fadeIn(400);
  };