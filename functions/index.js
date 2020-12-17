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



exports.findEmail = functions.https.onCall((data, context) => {
    var emails = []
    var usernames = []
    return db.collection('users').get()
        .then(snapshot => {
            snapshot.forEach(doc => {
                emails.push(doc.get("email"))
                usernames.push(doc.get("username"))
            })
            return
        })
        .then(function(message) {
            var email = ""
            for (i = 0; i < emails.length; i++) {
                if (usernames[i] === data.username) {
                    email = emails[i]  
                    break
                }
            }
            if (email.length === 0) {
                return "ERROR"
            } else {
                return email
            }
        })
        .catch(function(error) {
            console.log("error")
            return "Database Error"
        });
}) 

exports.createAccount = functions.https.onCall((data, context) => {
    
    var emails = []
    var usernames = []
    return db.collection('users').get()
        .then(snapshot => {
            snapshot.forEach(doc => {
                emails.push(doc.get("email"))
                usernames.push(doc.get("username"))
            })
            return
        })
        .then(function(message) {
            for (i = 0; i < emails.length; i++) {
                if (emails[i] === data.email) {
                    return "An account using this email already exists" 
                }
                if (usernames[i] === data.username) {
                    return "Username already exists" 
                }
            }
            return "SUCCESS"
        }).then(message => {
            var uid = ""
            if (message === "SUCCESS") {
                uid = admin.auth().createUser({
                    email: data.email,
                    username: data.username,
                    password: data.password
                })
                .then(function(userRecord) {
                    // See the UserRecord reference doc for the contents of userRecord.
                    console.log('Successfully created new user:', userRecord.uid);
                    return userRecord.uid
                })
                .catch(function(error) {
                    console.log('Error creating new user:', error);
                    return "Please fill out the fields correctly"
                });
            } else {
                return message
            } 
            return uid
            
        })
        .catch(function(error) {
            console.log("error")
            return "Database Error"
        });
});