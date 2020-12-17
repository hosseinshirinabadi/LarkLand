const functions = require('firebase-functions');

const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//

exports.createToken = functions.https.onCall((data, context) => {
    // console.log("hello world!!");
    var AccessToken = require('twilio').jwt.AccessToken;
    var VideoGrant = AccessToken.VideoGrant;
    // Substitute your Twilio AccountSid and ApiKey details
    var ACCOUNT_SID = 'ACc0f17af1913b97b5189ecbcda6fb3b6a';
    var API_KEY_SID = 'SKdbaa7a96a55e4e5af8bebe9d23073742';
    var API_KEY_SECRET = 'egiC0f3xdx1e8FUQLSZxmrGhrlshxTtm';
    // Create an Access Token
    var accessToken = new AccessToken(
    ACCOUNT_SID,
    API_KEY_SID,
    API_KEY_SECRET
    );
    // Set the Identity of this token
    accessToken.identity = data.username;
    // Grant access to Video
    var grant = new VideoGrant();
    grant.room = data.roomName;
    accessToken.addGrant(grant);
    // Serialize the token as a JWT
    var jwt = accessToken.toJwt();
    console.log(jwt);
    return jwt;
});