// **********************************************************************************
// Azure Bicep Module: Creating Function App (PowerShell)
// **********************************************************************************

param name string
param location string
param hostingplanName string
param storageaccountname string
param roledefinitionid string = 'acdd72a7-3385-48ef-bd42-f606fba81ae7' // RBAC Reader

// Fetching App Service Plan.

resource hostingplan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  name: hostingplanName
}

// Create Storage Account

resource storageaccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageaccountname
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

// Creating Function App

resource function 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingplan.id
    clientAffinityEnabled: true
    httpsOnly: true
    publicNetworkAccess: 'Enabled'
    siteConfig: {
      use32BitWorkerProcess: true
      ftpsState: 'FtpsOnly'
      alwaysOn: true
      powerShellVersion: '7.2'
      netFrameworkVersion: 'v6.0'
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'powershell'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageaccountname};AccountKey=${storageaccount.listKeys().keys[0].value}'
        }
      ]
    }
  }
}

resource roledefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: roledefinitionid
  scope: subscription()
}

resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, roledefinitionid)
  properties: {
    principalId: function.identity.principalId
    roleDefinitionId: roledefinition.id
    principalType: 'ServicePrincipal'
  }
}
