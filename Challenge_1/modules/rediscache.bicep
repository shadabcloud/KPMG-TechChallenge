param rediscachename string
param location string
param capacity int
param family string
param SkuName string
param publicaccess string

resource rediscache 'Microsoft.Cache/redis@2022-06-01' = {
  name: rediscachename
  location: location
  properties: {
    sku: {
      capacity: capacity
      family: family
      name: SkuName
    }
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    publicNetworkAccess: publicaccess
    redisVersion: '6.0'
  }
}

output rediscacheaccesskey string = rediscache.properties.accessKeys.primaryKey
output redisCacheID string = rediscache.id
