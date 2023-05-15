param appServicePlanName string
param location string
param Sku string
param SkuFamily string
param SkuTier string
param webappname string
param appservicesubnetId string
param rediscachename string
param resdiscacheaccesskey string
param staticwebappendpoint string

var redisconnectionstring = '${rediscachename}.redis.cache.windows.net:6380,password=${resdiscacheaccesskey},ssl=True,abortConnet=False'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  kind: 'webappwindows'
  properties: {
    reserved: false
    zoneRedundant: false
  }
  sku: {
    name: Sku
    size: Sku
    family: SkuFamily
    tier: SkuTier
  }
}

resource webapp 'Microsoft.Web/sites@2022-09-01' = {
  name: webappname
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    enabled: true
    reserved: false
    httpsOnly: true
    virtualNetworkSubnetId: appservicesubnetId
    siteConfig: {
      alwaysOn: true
      ftpsState: 'Disabled'
      scmMinTlsVersion: '1.2'
      numberOfWorkers: 1
      http20Enabled: false
      use32BitWorkerProcess: false
      vnetRouteAllEnabled: true
      webSocketsEnabled: false
      preWarmedInstanceCount: 1
      minTlsVersion: '1.2'
      javaContainer: 'JAVA'
      javaContainerVersion: 'SE'
      javaVersion: '11'
      healthCheckPath: '/'
      cors: {
        allowedOrigins: [
          staticwebappendpoint
        ]
      }
      appSettings: [
        {
          name: 'RedisConnString'
          value: redisconnectionstring
        }
      ]
    }
  }
}

resource vnetinjection 'Microsoft.Web/sites/networkconfig@2022-09-01' = {
  name: 'virtualNetwork'
  parent: webapp
  properties: {
    subnetResourceId: appservicesubnetId
    swiftSupported: true
  }
}

output AppServiceID string = webapp.id
