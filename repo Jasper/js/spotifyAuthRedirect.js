// JavaScript Document
$(document).ready(function(){
	var oURL = parseQueryString();
	var sAccessToken = oURL.access_token;
	var oUserData = getUserData(sAccessToken);

	localStorage.sSpotifyToken = sAccessToken;
	location.href = 'index.html';
});

// Comments
function getUserData(accessToken) {
	return $.ajax({
		url: 'https://api.spotify.com/v1/me',
		headers: {
		   'Authorization': 'Bearer ' + accessToken
		}
	});
}	
	
// Comments
function parseQueryString(){
	var vars = [], hash;
		var q = document.URL.split('#')[1];
		if(q != undefined){
			q = q.split('&');
			for(var i = 0; i < q.length; i++){
				hash = q[i].split('=');
				vars.push(hash[1]);
				vars[hash[0]] = hash[1];
			}
	}
	return vars;
}

