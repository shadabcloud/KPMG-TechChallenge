// **********************************************************************************
// Azure Bicep Module: Creating Function App (PowerShell)
// **********************************************************************************

param name string
param location string
param hostingplanName string
param storageaccountname string

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
