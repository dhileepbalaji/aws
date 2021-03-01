'use strict';

const AWS = require('aws-sdk');


const dynamoDb = new AWS.DynamoDB.DocumentClient();


exports.list = (event, context, callback) => {
    console.log("Receieved request to list all Users. Event is", event);
    var params = {
        TableName: process.env.USER_TABLE,
        ProjectionExpression: "UserId, Firstname, Lastname"
    };
    const onScan = (err, data) => {
        if (err) {
            console.log('Scan failed to load data. Error JSON:', JSON.stringify(err, null, 2));
            callback(err);
        } else {
            console.log("Scan succeeded.");
            return callback(null, successResponseBuilder(JSON.stringify({
                users: data.Items
            })
            ));
        }
    };
    dynamoDb.scan(params, onScan);
};


exports.get = (event, context, callback) => {
    console.log("Receieved request to get user details. Userid is",event.pathParameters.userid)
    const params = {
        TableName: process.env.USER_TABLE,
        Key: {
            UserId: parseInt(event.pathParameters.userid)
        },
    };
    dynamoDb.get(params)
        .promise()
        .then(result => {
            callback(null, successResponseBuilder(JSON.stringify(result.Item)));
        })
        .catch(error => {
            console.error("failed to find user",event.pathParameters.userid);
            callback(new Error('Couldn\'t fetch user.'));
            return;
        });
};

const successResponseBuilder = (body) => {
    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: body
    };
};


const failureResponseBuilder = (statusCode, body) => {
    return {
        statusCode: statusCode,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: body
    };
};