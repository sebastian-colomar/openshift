# NODEJS: Exercise with Github, Jenkins and Openshift Online

1. Login to your Gihub account
    1. Fork this project:
        - https://github.com/spring-projects/spring-petclinic
    1. Create a new branch for testing:
        - develop
1. Login to your Openshift Online account:
    1. Create a new project in Openshift Online:
        - playground
    1. Add a new Application from the Catalog:
        - Application type:
            - OpenJDK
        - Application Name: 
            - petclinic
        - Git Repository URL: 
            - https://github.com/USERNAME/spring-petclinic (your username in Github)
        - Git Reference:
            - develop (the name of the branch in the Github project)
        - Context Directory:
            - Leave it empty
        - Labels -> app:
            - petclinic
    1. Go to Builds -> Builds
        1. Select the corresponding Build:
            - petclinic
        1. Go to the Configuration tab and copy the following value:
            - GitHub Webhook URL
    1. Go to your project on Github and navigate to Settings -> Webhooks -> Add webhook
        - Payload URL:
            - Paste your Github Webhook URL
        - Content type:
            - application/json
    1. Go to the Overview page and check the status of your project
        - There is a URL link to the upper right of the page: visit your current application endpoint
1. Create the project for production in Openshift Online:
    1. Create a new project in Openshift Online:
        - production
    1. Add a new Application to your project:
        - Import YAML/JSON
        - Copy and paste the code from this page:
            - https://raw.githubusercontent.com/secobau/openshift/master/Openshift/petclinic.yaml
        - Process the template
        - Name:
            - petclinic
        - Git Repository URL:
            - https://github.com/USERNAME/spring-petclinic (your username in Github)
        - Labels -> app:
            - petclinic
    1. Go to Builds -> Pipelines:
        - Start Pipeline
        - Input Required
        - Log in with OpenShift
        - Allow selected permissions
        - Proceed
    1. Go to Builds -> Pipelines:
        1. Select the corresponding Pipeline:
            - bluegreen-pipeline
        1. Go to the Configuration tab and copy the following value:
            - GitHub Webhook URL
    1. Go to your project on Github and navigate to Settings -> Webhooks -> Add webhook
        - Payload URL:
            - Paste your Github Webhook URL
        - Content type:
            - application/json
1. Change the code in Github:
    1. Go to your fork of the project:
        - https://github.com/USERNAME/spring-petclinic (your username in Github)
    1. Checkout to the develop branch
    1. Navigate to the following resource:
        - https://github.com/USERNAME/spring-petclinic/blob/develop/src/main/resources/templates/welcome.html (your username in Github)
    1. Modify the existing code:
        - Delete line number 7
    1. Instead of committing directly the changes to the develop branch:
        - Create a new branch for this commit and start a pull request
        - Propose file change
        - Create pull request
        - Merge pull request
        - Confirm merge
        - Delete branch
1. Verify the changes in Openshift Online:
    1. Go to your playground project
    1. Go to Overview -> petclinic
        - Visit the URL of the application
1. Promote the changes to the master branch:
    1. Go to your fork of the project:
        - https://github.com/USERNAME/spring-petclinic (your username in Github)
    1. Navigate to the following resource:
        - https://github.com/USERNAME/spring-petclinic/pulls (your username in Github)
    1. New Pull Request
        - Comparing changes
        - base repository:
            - USERNAME/spring-petclinic (your username in Github)
        - compare:
            - develop
        - Create pull request
        - Merge pull request
        - Confirm merge
1. Verify the changes in Openshift Online:
    1. Go to your production project
    1. Go to Builds -> Pipelines:
        - Input Required
        - Log in with OpenShift
        - Allow selected permissions
        - Proceed
    1. Go to Overview -> petclinic
        - Visit the URL of the application
