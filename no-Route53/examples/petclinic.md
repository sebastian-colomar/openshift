# PETCLINIC: Exercise with Github and Openshift Online

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
            - develop
        - Context Directory:
            - Leave it empty
         - Labels -> app:
            - petclinic
    1. Go to Applications -> Deployments
        1. Select the corresponding Deployment:
            - petclinic
        1. Click on the Actions selector to the upper right of the page and select:
            - Edit Resource Limits
        1. Edit the Memory limit:
            - 2 GiB        
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
    1. Go to Overview -> petclinic
        - Visit the URL of the application
