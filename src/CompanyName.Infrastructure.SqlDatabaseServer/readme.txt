Deployment example (in powershell): 

1. login to your account

Login-AzureRmAccount

2. select your subscription

Select-AzureRmSubscription -SubscriptionName 'Strobbo-DEV'

3. deploy arm template

.\Deploy-Dev.ps1

or

.\Deploy-Test.ps1

or (manual)

.\Deploy-AzureResourceGroup.ps1 -TemplateParametersFile .\parameters-<Env>.json



extra: do Get-AzSqlServerServiceObjective -Location "West Europe" to find out db types