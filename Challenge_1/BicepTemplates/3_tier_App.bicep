// Defining Scope

targetScope = 'subscription'

// Declaring Parameters

param subscriptionId string = 'xxxxxxxxxxxxxxxxxxxx'
param rgname string = 'Demo-RG'
param location string = 'westeurope'
param keyVaultname string = 'Demo-KV'




// Creating Resources

module keyvault '../modules/keyvault.bicep' = {
  scope: resourceGroup(subscriptionId, rgname)
  name: keyVaultname
  params: {
    appgwsubnetId: 
    appgwUMIName: 
    iprules: 
    keyvaultName: 
    location: 
  }
}
