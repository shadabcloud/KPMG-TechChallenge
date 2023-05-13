// **********************************************************************************
// Azure Bicep Module: Creating App Service Plan.
// **********************************************************************************

param name string
param location string

resource appserviceplan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  location: location
  sku: {
   name: 'S1'
  }
}
