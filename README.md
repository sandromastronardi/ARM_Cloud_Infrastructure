# ARM Cloud Infrastructure
Example ARM structure for deploying a global infrastructure on the Azure Cloud
Source: https://github.com/sandromastronardi/ARM_Cloud_Infrastructure

## Introduction 
The infrastructure project contains all global infrastructure configuration templates.
It will deploy environments for the following azure services:

*	Dns
*	Event Grid
*   Cosmos DB
*   Sql Servers
*	Key Vaults
*	Acme Certificates for Key Vault

## Getting Started
When you use this code for the first time search and replace these things:
  *  `Comp` with your company prefix (short name)
  *  `CompanyName` with your company name (longer name, but not EXTREMELY long :))

Also search for `putyourpassword` and replace it with your passwords (make them different per environment and datasource) 
For auth0 search for Username-Password-Authentication and replace it with your own (if its different)

To add an infrastructure do as follows:
1.	Create ARM Project
2.	Reference it from the CompanyName.Infrastructure.Deploy as a linked ARM template
3.	Push/Sync to Devops
4.	It will be deployed to the specific environment

## How it works
This set of scripts will create an environment for you that will work like this:

*	SQL Servers in the regions that you define
*   CosmosDB in the regions that you define
*   Sql Servers in the regions you define
*   Event Grid in the regions you define
*   Key Vaults for each region (for region specific keys)
*   A Global Key vault for general settings and Certificates
*   Acme Key Vault application for registering certificates (and autorenewal)
*   The scripts must be deployed to a storage account so that the following scripts can be used in other projects:
    *   Function App deployments
    *   SQL Databases for each service
    *   Subscriptions to Event Grid Events (Http Request)

You execute the `CompanyName.Infrastructure.Deploy/MainDeployment/azuredeploy.json` to initiate deployment of all these scripts.  
They must first be copied to a blob storage, for that you can use the `CompanyName.Infrastructure.Deploy/Storage/azuredeploy.json` template in your deployment pipeline

## Naming Schemes

You must rename CompanyName everywhere with your company name so you create your custom environment.
It will create the following schemes

### For DNS

When you have done your replacements you have also found your DNS domains, you can configure these for your 4 environments (Dev, Test, Acc and Prod)  
It is advised to add all DNS entries trough these templates.  Entries for your azure apps will be auto-configured in their respective templates.

### For Sql Servers & Databases

Resource Group: `{CompanyName}.{Env}.{Region}`  
Where Env is either `Dev`, `Test`, `Acc` or `Prod` and region is the regioncode you define, for example `WEU`, `NEU`, `NUS`, etc... (you can choose them, I recommend 3 letters)  
Sql Server name: `{CompanyName}-{Env}-{Region}`  
The database will be named later with the database ARM template.  It will be the servicename followed by main (for the default) or another name for additional databases if needed.  
So it will be like: `{ServiceName}-main` or `{ServiceName}-something`

### Cosmos DB

For cosmosdb you can create multiple Cosmos databases, depending on the API used.
For example a cosmosdb with sql for the dev environment will look like this: `companyname-dev-sql`  
So the format is `{companyname}-{env}-{type}`  
Where Env is either `dev`, `test`, `acc` or `prod` and region is the regioncode you define, for example `WEU`, `NEU`, `NUS`, etc... (you can choose them, I recommend 3 letters)  
They are used in lowercase, the config is in PascalCase

Inside this cosmosdb you can have your collections like `{ObjectType}Events` & `{ObjectType}s`
The events collection is for eventstores.  See the shared library to be used with these templates. (https://github.com/sandromastronardi/CloudInfra_Shared_Libraries)

Collections are made with the ARM template in the folder CollectionsTemplate under the CosmosDB project.

### Event Grid
Resource Group: `{CompanyName}.{Env}.{Region}`  
Where Env is either `Dev`, `Test`, `Acc` or `Prod` and region is the regioncode you define, for example `WEU`, `NEU`, `NUS`, etc... (you can choose them, I recommend 3 letters)  

When you deploy a function app service and enable Eventgrid for it a topic will be created with the name of the service.
Then when you use the ARM in the Subscriptions folder you will have a subscription with this naming scheme:  
`{Prefix}{Env}-{Region}-{ServiceName}-Func-{WorkerApi}`
*   Where Prefix is the prefix you replace (from Comp) when you start with these templates.  
*   Where Env is either `Dev`, `Test`, `Acc` or `Prod`  
*   Where Region is the regioncode you define, for example `WEU`, `NEU`, `NUS`, etc... (you can choose them, I recommend 3 letters)  
*   Where ServiceName is the name of your service, for example Customers, Accounts, etc...
*   Where Func is the type of service subscription (azure function, this is static in the ARM template for the subscription)
*   Where WorkerApi is the chosen service subtype (WorkerApi is the background worker process, recommended to handle events instead of your frontend facing API)

### Key Vaults

There are two types of Keyvaults: Regional and a Global.
For each region there can be different keys and thus those are stored in the Regional key vaults.  
When you want to store a config value (usually a manually added one) you do so in a Global keyvault.
You can have multiple keyvaults per region or global too.
The default one looks like this:  
`{Prefix}{Env}-main-{Region}` so something like `CompDev-main-WEU`  
or for Global:
`{Prefix}{Env}-main-Global` so something like `CompDev-main-Global`
The global and default regional keyvaults (main) are added with the main deployment template.  Creating others can be done by individual invocation of the keyvaults ARM template.
In the `CompanyName.Infrastructire.Deploy/MainDeployment/azuredeploy.json` you can change its region from WestEurope to whatever you want.

### Lets Encrypt



## Build and Test
During build a json check will be done to validate all json files

For deployment permissions are required for Azure Devops (CompanyName-Infrastructure) in the CompanyName.ENV Resource group (Dev, Test, Acc, Prod) as contributor to add permissions to manage DNS.
this becomes clear when you get this error:

At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/DeployOperations for usage details.
Details:
InvalidTemplateDeployment: The template deployment failed with error: 'Authorization failed for template resource '2d1cdb97-4974-4da9-9625-8ffb821f65dc' of type 'Microsoft.Authorization/roleAssignments'. The client '5764f80b-d5bb-40c9-964a-80a635a4f694' with object id '5764f80b-d5bb-40c9-964a-80a635a4f694' does not have permission to perform action 'Microsoft.Authorization/roleAssignments/write' at scope '/subscriptions/253bcd96-8ec8-47dc-9925-a8fe695112db/resourceGroups/CompanyName.Dev/providers/Microsoft.Authorization/roleAssignments/2d1cdb97-4974-4da9-9625-8ffb821f65dc'.'.
Check out the troubleshooting guide to see if your issue is addressed: https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/deploy/azure-resource-group-deployment?view=azure-devops#troubleshooting
Task failed while creating or updating the template deployment.

To fix this ad that entity to the resource group to allow the script to add the dns permissions to the resource group.
https://docs.microsoft.com/en-us/answers/questions/287573/authorization-failed-when-when-writing-a-roleassig.html
Add Owner or 'Beheerder van gebruikerstoegang' or create role with roleAssignments/write permision

## How it all works together

### Function App

The function app is where most of this comes together.
To deploy a function app it will require a database (Sql/Cosmos) and it will probably use the eventgrid, it will have a DNS record, and use keyvault values.
To get started we do this in our pipeline.  

First of all we need to create a SAS token to access our deployment storage account, use the 'Create SAS Token' task.
Then you will download the required files:
*   The function app template
*   The event grid subscription template
*   The sql Database template (or)
*   The cosmos DB Collection template

Then you deploy your SQL database in the RG `CompanyName.Dev.WEU` (or other env or region)

***What I do recommend is that when you deploy to dev you access the templates directly from your storage account.
For production, or probably even Acceptance you download them in the build pipeline and add them to the artifacts there.  That way the template matches the code that is being deployed, and a redeploy will always be consistent.  
During Dev stages it saves time to download them in your release pipeline since you can quickly make changes in your ARM template, deploy to storage account, and re-release your app right away, without doing a rebuild.  In production you obviously don't want that, but by then your template has been tested and added to the artifact.***

You can parse the output for later use, for example to use in the Redgate SQL Change Automation for deploying your database

The next step is to deploy the Function App itself:

This is the most complicated script in this project to date.  It will do everything in one deploy.  You do need some prerequisites:  
The default configuration for the script is to create a subdomain for your service like `{servicename}-{api}.services.{region}.{dnsroot}`  
For this to work you need to have a `wildcard-services-{region}-{dnsroot}` certificate in your global keyvault.  You need to create that as described above with your Lets encrypt application.

#### DNS

It will create the DNS records for you automatically, it will do the validation records (asuid TXT record) and it will create the record. It will also connect the certificate for your default configured hostname.
It is possible to provide an alternate name, for example something more generic for frontend use (without 'services' in the subdomain) and that will also be created in DNS as a secondary, and also that certificate must exist for it to be set.
The certificates are loaded from the keyvault, and when it is renewed by your Letsencrypt Acme tool it will renew in your functionapp within 48 hours.

#### Deploy Slot

The function app always gets a deploy slot from which you can swap your code to production. Either fully or gradually.
There are some configuration values to allow you to disable certain functions, or to modify your apps behaviour.

`IsDeploySlot` is either true or false, and can be used in your code.  
`HandlersDisabled` is 1 in the deploy slot and 0 in production, by adding the `[Disable("HandlersDisabled")]` attribute before your function you will disable it only in the deploy slot.

#### Sql Databases

To create a SQL Database you use these parameters for creating the database, you can define in which regions the keys are stored for use in your app

    {
      "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {
        "environment": {
          "value": "Dev"
        },
        "location": {
          "value": "WestEurope"
        },
        "locationCode": {
          "value": "WEU"
        },
        "serviceName": {
          "value": "Customers"
        },
        "usageRegions": {
          "value": [
            {
              "location": "WestEurope",
              "locationCode": "WEU"
            },
            {
              "location": "NorthEurope",
              "locationCode": "NEU"
            }
          ]
        }
      }
    }

When you need multiple databases to replicate to, you must create them too and setup replication (not yet included in the templates)

Then to use the database you simply add this parameter to your parameters file:
    
    ...
    "sqlDatabases": {
      "value": [ "main" ]
    }
    ...

your Customers-main database will be used in this case.  It will add a rw and ro connection string to your appsettings.

#### Company Global key vault settings

When you want to use your global key vault settings in your application you can configure them like this:

    "keyVaultGlobalAppSettings": {
        "value": [
        {
            "name": "IdentitySettings__ClientID",
            "keyName": "Microservice-ClientID"
        }]
    }

`keyName` is the key vault secret name you want to connect, and name is the name that will be given to this configurationsetting.
They are both full names, as they are global, and some might be reused across services.  
If you add `vaultName` you can manually choose another Global key vault instead of main... (the prefix and suffix remain the same, you only replace main with something else)


#### App specific key vault settings

When you want to set application specific settings you can use this:

    "keyVaultAppSettings": {
      "value": [
        "Auth0ManagementClientID",
        "Auth0ManagementSecret"
      ]
    },

It will read from your Global !! key vault but with the application prefix. So if your application is the Customers service then this will work like this:

The app setting will be Auth0ManagementClientID but it will retrieve from your global settings (main) with the prefix Customers-Auth0ManagementClientID.
This way you only set up the main setting name, and the prefixing is done automatically.

#### Generic App Setings

When you want to setup appsettings that are not coming from your key vault you can just provide it like this:

    "appSettings": {
      "value": [
        {
          "name": "AUTH0_LocalConnection",
          "value": "Username-Password-Authentication"
        }
      ]
    },

  These will be joined with the other appsettings that your application will get.

  Other settings that can be autoconfigured are the authorisation settings, by adding this

    "addAuthorisation": {
      "value": true
    },

or adding Event Grid settings by using this

    "addEventGrid": {
      "value": true
    },

The settings that you usually configure troughout these templates are these:
    
    "environment": {
      "value": "Dev"
    },
    "serviceName": {
      "value": "Users"
    },
    "serviceType": {
      "value": "Api"
    },
    "locationCode": {
      "value": "WEU"
    }

These make up the naming scheme in general.
the environment (`Dev`, `Test`, `Acc` or `Prod`)
The location code (the region itself is set with the resource group)
The service type (this is basically a free type field, but this is how we use it initially):

*   `Api` is the front end facing Api.
*   `WorkerApi` is the backend processing service (for queue's, webhooks, etc...)
*   Then you might have other endpoints that are used to provide other content (Html, redirects, etc...)
    * `Gateway` (for a payment redirect gateway)
    * `Connect` (for an endpoint for generating connection information to your service (with for example a QR generator)
    *  ***When you use these other instances you might want to use these with custom hostnames like `payments.companyname.com`***

(The Api and WorkerApi approach is based on the Content Reactor Serverless Microservice Example for Azure: https://learn.microsoft.com/en-us/samples/azure-samples/serverless-eventing-platform-for-microservices/serverless-eventing-platform-for-microservices/)

#### Event subscriptions

After release of your function app (ARM **AND** Code) you can now subscribe it to your event grid topics.
You can do so with the ARM template in `CompanyName.Infrastructure.EventGrid/Subscriptions/azuredeploy.json`

You can use a `parameters.json` like this:

    {
      "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {
        "serviceType": {
          "value": "WorkerApi"
        },
        "environment": {
          "value": "Dev"
        },
        "serviceName": {
          "value": "Download"
        },
        "topicName": {
          "value": "documents"
        },
        "locationCode": {
          "value": "WEU"
        },
        "location": {
          "value": "WestEurope"
        },
        "webHook": {
          "value": "/api/download"
        },
        //"hostNameOverride": {
        //  "value": "customname.eu.ngrok.io"
        //},
        "eventTypes": {
          "value": [
            "DocumentCreated"
          ]
        },
        "advancedFilters": {
          "value": [
            {
              "operatorType": "BoolEquals",
              "key": "data.Download",
              "value": true
            }
          ]
        }
      }
    }

You can set the `eventTypes` for which you want to subscribe, and also provide advanced filters as per ARM specifications: https://learn.microsoft.com/en-us/azure/event-grid/event-filtering#operators

It is also possible to set a `hostNameOverride` to specify a different hostname for the webhook endpoint.  
If you don't specify it will use the hostname based on the same conventions to create your custom hostname under your environment root. (With SSL)
The `hostNameOverride` is commented out in the sample above. (it overrides only the hostname, ssl is still required)  
With www.ngrok.com you can make a tunnel to your localhost to test these subscriptions locally.

## Web App

This is not yet available, but it will work the same as the function app
