// Declare Pramaters

param vnetname string
param location string
param AppServiceSubnetNSGName string
param PLESubnetNSGName string
param appservicesubnetprefix string
param plesubnetprefix string
param vnetaddressprefix string

// Create NSG and Security Rules

resource AppServiceNSG 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: AppServiceSubnetNSGName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Deny_All_In'
        properties: {
          priority: 2000
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          protocol: '*'
          destinationAddressPrefix: appservicesubnetprefix
          destinationPortRange: '*'
          description: 'Deny all traffic to appservice subnet'
        }
      }
      {
        name: 'AppserviceSubnet_To_PLESubnet_Out'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Outbound'
          sourceAddressPrefix: appservicesubnetprefix
          sourcePortRange: '*'
          protocol: 'Tcp'
          destinationAddressPrefix: plesubnetprefix
          destinationPortRanges: [
            '1433'
            '6380'
          ]
          description: 'Allow_AppserviceSubnet to PLE Subnet for SQL and Redis connections'
        }
      }
      {
        name: 'Deny_All_Out'
        properties: {
          priority: 2000
          access: 'Deny'
          direction: 'Outbound'
          sourceAddressPrefix: appservicesubnetprefix
          sourcePortRange: '*'
          protocol: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          description: 'Deny all traffic from appservice subnet'
        }
      }
    ]
  }
}

resource PLESubnetNSG 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: PLESubnetNSGName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Deny_All_In'
        properties: {
          priority: 2000
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          protocol: '*'
          destinationAddressPrefix: plesubnetprefix
          destinationPortRange: '*'
          description: 'Deny all traffic to ple subnet'
        }
      }
      {
        name: 'AppserviceSubnet_To_PLESubnet_In'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: appservicesubnetprefix
          sourcePortRange: '*'
          protocol: 'Tcp'
          destinationAddressPrefix: plesubnetprefix
          destinationPortRanges: [
            '1433'
            '6380'
          ]
          description: 'Allow_AppserviceSubnet to PLE Subnet for SQL and Redis connections'
        }
      }
      {
        name: 'Deny_All_Out'
        properties: {
          priority: 2000
          access: 'Deny'
          direction: 'Outbound'
          sourceAddressPrefix: plesubnetprefix
          sourcePortRange: '*'
          protocol: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          description: 'Deny all traffic from ple subnet'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetname
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetaddressprefix
      ]
    }
    subnets: [
      {
        properties: {
          addressPrefix: appservicesubnetprefix
          networkSecurityGroup: {
            id: AppServiceNSG.id
          }
        }
      }
      {
        properties: {
          addressPrefix: plesubnetprefix
          networkSecurityGroup: {
            id: PLESubnetNSG.id
          }
        }
      }
    ]
  }
}
