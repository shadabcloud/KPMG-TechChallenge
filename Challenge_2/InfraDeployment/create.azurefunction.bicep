// Setting Deployment Scope.

targetScope = 'subscription'

// Declaring Parameters.

param subscriptionID string = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
param rgeusname string = 'FunctionApp-RG'
param rgeuslocation string = 'eastus'
param rgeushostingplanName string = 'AppPlan-EUS'
param rgeusfunctionappname string = 'FunctionApp-EUS'
param storageaccountname string = 'functionstorage'

// Creating Resource Group RG-EUS.

resource RGEUS 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgeusname
  location: rgeuslocation
}

// Creating App Service Plan

module EUSAppServicePlan 'Bicepmodule/azureappserviceplan.bicep' = {
  name: 'eushostingplandeploy'
  scope: resourceGroup(subscriptionID, rgeusname)
  dependsOn: [
    RGEUS
  ]
  params: {
    location: rgeuslocation
    name: rgeushostingplanName
  }
}

// Creating Azure Function with PowerShell Core runtime

module FunctionApp 'Bicepmodule/azurefunctionapp.bicep' = {
  name: 'deployfunctionapp'
  scope: resourceGroup(subscriptionID, rgeusname) 
  dependsOn: [
    EUSAppServicePlan
  ]
  params: {
    hostingplanName: rgeushostingplanName
    location: rgeuslocation
    name: rgeusfunctionappname
    storageaccountname: storageaccountname
  }
}

