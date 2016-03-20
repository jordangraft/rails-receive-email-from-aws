# Receive email from AWS Lambda & SES with Rails

Basic Rails app that demonstrates how to receive email from an AWS Lambda process.  Works for Rails apps where you want users to be able to send in emails.

## Setup AWS S3, Lambda, and SES
We will start with getting all the pieces in place in our AWS account for receiving emails, storing them in an S3 bucket, and setting up a Lambda function to post to our Rails app.

### S3 Bucket for SES to Store Emails
You will need to create a standard S3 bucket with a custom configuration for SES to store emails.

1. Create an S3 Bucket
2. Update the permissions rules with the following:
```
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "GiveSESPermissionToWriteEmail",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "ses.amazonaws.com"
                ]
            },
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::BUCKET-NAME/*",
            "Condition": {
                "StringEquals": {
                    "aws:Referer": "ACCOUNT-ID-WITHOUT-HYPHENS"
                }
            }
        }
    ]
}
```

### AWS Lambda function to process incoming mail

1. Click on Lambda from your AWS Console
2. Click Create New Function from the Lambda console
3. On the Select Blueprint screen, click Skip at the bottom right
4. Enter a name and description for your Lambda function and paste in the following code.  Replace the domain 'http://example.com' with the domain where you are deploying.

![Image of Lambda Setup](tutorial/lambda_setup.png)
5. For Role, just select basic execution role and a new tab will open inside your IAM console asking to create this new role.
![Image of New Role](tutorial/new_role.png)
6. (Optional) Choose a VPC for where to deploy the function
7. Click Create Function

You also have the option to save and test the function which will be helpful once you get your Rails app deployed to make sure everything is working in production.


### Setting up AWS SES to receive mail

Setup the domain for which you want to receive mail.  We typically use a subdomain so that it doesn't interfere with our normal company email @cratebind.com

![Image of SES New Domain](tutorial/setup_ses_domain_cb.png)
   

Update your DNS record to point the subdomain MX records to SES.  The Value field depends on the AWS region in which your SES domain was setup.  For our account, we are using us-west-2 so our MX records would be as follows:
![Image of Route 53 Setup](tutorial/route53_setup.png)

Lastly, you will create a new default rule in SES for how to process incoming messages.

1. Go to SES in your AWS Dashboard
2. Click on Rule Sets
3. Click Create Rule Set
![Create Rule Set](tutorial/create_rule_set.png)
4. Once you have created the Rule Set, now you need to create a Rule
5. In the create Rule screen, add the recipient.  You can read the instructions on this screen for how to setup a wilcard rule.  For our case, we will just create a recipient for recipient@emails.cratebind.com
![Create Rule Set](tutorial/create_recipient.png)
6. Confgure the actions for the rule.  Here are the steps: (1) save email to S3, (2) trigger our AWS Lambda function and (3) Stop Processing.
![SES Configuration](tutorial/ses_config.png)
7. You will need to update your specified S3 bucket with the following permission set in order for SES to be able to put the messages (instructions above)

Additional instructions on setting up SES to receive email if you get stuck [AWS SES Email Receiving Tutorial](http://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-setting-up.html)

## Setup Your Rails App

### Generate model for receive emails
Create a basic model and controller that will receive the post response from AWS Lambda and save the email in the database.

```
rails g scaffold email from:string body:text to:string
```

### Model Method
We will use Webmock and stub data to test that we have the correct controller and model actions in place to process the data we receive from AWS Lambda.

Our basic setup will be for our AWS Lambda function to store the incoming message in our S3 bucket and then post the message id to our Rails app.  So we will first build a class method in our Email model that takes the message_id and pulls the email from the S3 bucket and saves it to our database

We have created a example message that represents the text file saved by AWS SES to S3 and we will write a test that stubs this message from the get request to our S3 bucket in spec/models/email_spec.rb

This is the Webmock setting to stub the request to S3:

```
#spec/rails_helper.rb
  config.before do
    WebMock.disable_net_connect!(allow_localhost: true)
    stub_request(:get, "https://my-email-bucket.s3.amazonaws.com/test")
      .to_return(status: 200, body: File.read('spec/support/lambda_email'))
  end
```

### Controller Action
Next we will build a test to spec the controller action that receive the POST from AWS Lambda, validates the token and passes the message_id to the model method we just build and tested.