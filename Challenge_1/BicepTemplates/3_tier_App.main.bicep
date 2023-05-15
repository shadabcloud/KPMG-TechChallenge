// Defining Scope

targetScope = 'subscription'

// Declaring Parameters

param subscriptionId string
param rgname string
param location string
param plesubnetid string
param keyVaultname string
param appgwsubnetId string
param appgwUMIName string
param kviprules array
param storageAccountName string
param storageSku string
param storageaccountipRules array
param storageaccessTier string
param rediscachename string
param rediscapacity int
param redisfamily string
param redisSkuName string
param redispublicaccess string
param sqlServerName string
param sqlServeradminLoginSPN string
param sqlServeradminSidSPN string
param DBName string
param DBSkuTier string
param DBSkuName string
param DBMaxSizeinBytes int
param DBZoneRedundancy bool
param DBstorageredundancy string
param appServicePlanName string
param appServicePlanSku string
param appServicePlanSkuFamily string
param appServicePlanSkuTier string
param webappname string
param appservicesubnetId string
param staticwebappendpoint string
param appgwName string
param appgwSkuName string
param instancecount int
param appgwprivateIP string
param BPFQDN string
param sslcertName string

// Deploy KeyVault

module keyvault '../modules/keyvault.bicep' = {
  scope: resourceGroup(subscriptionId, rgname)
  name: keyVaultname
  params: {
    appgwsubnetId: appgwsubnetId 
    appgwUMIName: appgwUMIName
    iprules: kviprules
    keyvaultName: keyVaultname
    location: location
  }
}

module KeyVaultPLE '../modules/privatelinkendpoint.bicep' = {
  scope: resourceGroup(subscriptionId, rgname)
  name: 'kvpledeploy'
  params: {
    groupId: 'vault'
    location: location
    PLEname: '${keyVaultname}-PLE'
    PLEserviceId: keyvault.outputs.keyVaultID
    PLEsubnetId: plesubnetid
  }
}

// Deploy Storage Account

module storageAccount '../modules/storageaccount.bicep' = {
  scope: resourceGroup(subscriptionId, rgname)
  name: storageAccountName
  params: {
    accessTier: storageaccessTier
    ipRules: storageaccountipRules
    location: location
    storageAccountName: storageAccountName
    storageSku: storageSku
  }
}

module blobple '../modules/privatelinkendpoint.bicep' = {
  scope: resourceGroup(subscriptionId, rgname)
  name: 'blobpledeploy'
  params: {
    groupId: 'blob'
    location: location
    PLEname: '${storageAccountName}-blob-PLE'
    PLEserviceId: storageAccount.outputs.storageAccountID
    PLEsubnetId: plesubnetid
  }
}

// Deploy Application Gateway

module AppGW '../modules/applicationgateway.bicep' = {
  scope: resourceGroup(subscriptionId, rgname)
  name: 'appGWdeploy'
  params: {
    appgwName: appgwName
    appgwprivateIP: appgwprivateIP
    appgwSkuName: appgwSkuName
    appgwsubnetId: appgwsubnetId
    appgwUMIName: appgwUMIName
    BPFQDN: BPFQDN
    instancecount: instancecount
    keyvaultName: keyVaultname
    location: location
    sslcertName: sslcertName
  }
}

// Deploy Redis Cache

module redisCache '../modules/rediscache.bicep' = {
  scope: resourceGroup(subscriptionId, rgname)
  name: rediscachename
  params: {
    capacity: rediscapacity
    family: redisfamily
    location: location
    publicaccess: redispublicaccess
    rediscachename: rediscachename
    SkuName: redisSkuName
  }
}

module RediscachePLE '../modules/privatelinkendpoint.bicep' = {
  scope: resourceGroup(subscriptionId, rgname)
  name: 'redispledeploy'
  params: {
    groupId: 'redisCache'
    location: location
    PLEname: '${redisCache}-PLE'
    PLEserviceId: redisCache.outputs.redisCacheID
    PLEsubnetId: plesubnetid
  }
}

// Deploy SQL Server

module sqlServer '../modules/sqlserver.bicep' = {
  scope: resourceGroup(subscriptionId, rgname)
  name: sqlServerName
  params: {
    adminLoginSPN: sqlServeradminLoginSPN
    adminSidSPN: sqlServeradminSidSPN
    location: location
    sqlServerName: sqlServeradminSidSPN
  }
}

module sqlServerPLE '../modules/privatelinkendpoint.bicep' = {
  scope: resourceGroup(subscriptionId, rgname)
  name: 'sqlServerPLEDeploy'
  params: {
    groupId: 'sqlServer'
    location: location
    PLEname: '${sqlServerName}-PLE'
    PLEserviceId: sqlServer.outputs.sqlServerId
    PLEsubnetId: plesubnetid
  }
}

// Deploy SQL Database 

module sqlDB '../modules/sqlDB.bicep' = {
  scope: resourceGroup(subscriptionId, rgname)
  name: DBName
  params: {
    DBName: DBName
    DBSkuName: DBSkuName
    DBSkuTier: DBSkuTier
    location: location
    MaxSizeinBytes: DBMaxSizeinBytes
    sqlServerName: sqlServerName
    storageredundancy: DBstorageredundancy 
    ZoneRedundancy: DBZoneRedundancy
  }
}

// Deploy App Service

module AppService '../modules/appservice.bicep' = {
  scope: resourceGroup(subscriptionId, rgname)
  name: 'appservicecomponentsdeploy'
  params: {
    appServicePlanName: appServicePlanName
    appservicesubnetId: appservicesubnetId
    location: location
    rediscachename: rediscachename
    resdiscacheaccesskey: redisCache.outputs.rediscacheaccesskey
    Sku: appServicePlanSku
    SkuFamily: appServicePlanSkuFamily
    SkuTier: appServicePlanSkuTier
    staticwebappendpoint: staticwebappendpoint
    webappname: webappname
  }
}

module AppServicePLE '../modules/privatelinkendpoint.bicep' = {
  scope: resourceGroup(subscriptionId, rgname)
  name: 'appservicePLEdeploy'
  params: {
    groupId: 'sites'
    location: location
    PLEname: '${webappname}-PLE'
    PLEserviceId: AppService.outputs.AppServiceID
    PLEsubnetId: plesubnetid
  }
}
