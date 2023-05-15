param keyvaultName string
param location string
param iprules array
param appgwUMIName string
param appgwsubnetId string

resource appgwUMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: appgwUMIName
  location: location
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyvaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableRbacAuthorization: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 60
    enablePurgeProtection: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [for ipRange in iprules: {
        value: ipRange
      }]
      virtualNetworkRules: [
        {
          id: appgwsubnetId
          ignoreMissingVnetServiceEndpoint: false
        }
      ]
    }
    accessPolicies: [
      {
        applicationId: appgwUMI.properties.clientId
        objectId: appgwUMI.properties.principalId
        tenantId: subscription().tenantId
        permissions: {
          certificates: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

output keyVaultID string = keyVault.id
