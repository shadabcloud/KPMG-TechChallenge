param appgwName string
param location string
param appgwSkuName string
param instancecount int
param appgwsubnetId string
param appgwprivateIP string
param BPFQDN string
param keyvaultName string
param sslcertName string
param appgwUMIName string

resource appgwUMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: appgwUMIName
}

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyvaultName
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: '${appgwName}-PIP'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

resource appgw 'Microsoft.Network/applicationGateways@2022-11-01' = {
  name: appgwName
  location: location
  zones: null
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${appgwUMI.id}': {}
    }
  }
  properties: {
    sku: {
      name: appgwSkuName
      tier: appgwSkuName
      capacity: instancecount
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: appgwsubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIpIPv4'
        properties: {
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
      {
        name: 'appGwPrivateFrontendIpIPv4'
        properties: {
          subnet: {
            id: appgwsubnetId
          }
          privateIPAddress: appgwprivateIP
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'StaticApp-BP'
        properties: {
          backendAddresses: [
            {
              ipAddress: null
              fqdn: BPFQDN
            }
          ]
        }
      }
    ]
    probes: [
      {
        name: 'StaticApp-HealthProbe'
        properties: {
          protocol: 'Https'
          pickHostNameFromBackendHttpSettings: true
          port: 443
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 5
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'StaticApp-BackendHTTPSettings'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 60
          probeEnabled: true
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appgwName, 'StaticApp-HealthProbe')
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'StaticApp-HTTPs-Listner'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appgwName, 'appGwPrivateFrontendIpIPv4')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appgwName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appgwName, sslcertName)
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'StaticApp-RoutingRules'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpsListeners', appgwName, 'StaticApp-Https-Listner')
          }
          priority: 100
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appgwName, 'StaticApp-BP')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appgwName, 'StaticApp-BackendHTTPSettings')
          }
        }
      }
    ]
    enableHttp2: false
    sslCertificates: [
      {
        name: sslcertName
        properties: {
          keyVaultSecretId: '${keyvault.properties.vaultUri}secrets/${sslcertName}'
        }
      }
    ]
    sslPolicy: {
      policyType: 'Predefined'
      policyName: 'AppGwSslPolicy20170401S'
    }
  }
}
