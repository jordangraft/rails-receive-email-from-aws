var AWS = require('aws-sdk');
var https = require('https');

exports.handler = function(event, context) {

    var sesNotification = event.Records[0].ses;
    var messageId = sesNotification.mail.messageId;
    var receipt = sesNotification.receipt;
    var from = sesNotification.mail.commonHeaders.from[0];
    var appUrl = 'https://www.example.com'
    var options = {
        host: 'www.example.com',
        port: 443,
        path: '/emails/incoming?token=test_token&message_id=' + messageId,
        method: 'POST',
        headers: {}
    };
    console.log('message ID', messageId);

    var req = https.request(options, function(res) {
        context.succeed();
        console.log('STATUS: ' + res.statusCode);
        res.on('data', function(chunk) {
            console.log('BODY: ' + chunk);
        });
    }).on('error', function(e) {
        console.log('FAILIRE: ' + e.message)
        context.done(null, 'FAILURE');
    });
    req.end();
}