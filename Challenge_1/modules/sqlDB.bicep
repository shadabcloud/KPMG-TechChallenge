param sqlServerName string
param location string
param DBName string
param DBSkuTier string
param DBSkuName string
param MaxSizeinBytes int
param ZoneRedundancy bool
param storageredundancy string

resource database 'Microsoft.Sql/servers/databases@2022-08-01-preview' = {
  name: '${sqlServerName}/${DBName}'
  location: location
  sku: {
    name: DBSkuName
    tier: DBSkuTier
  }
  properties: {
    collation: 'SQL_Latin_General_CP1_CI_AS'
    maxSizeBytes: MaxSizeinBytes
    zoneRedundant: ZoneRedundancy
    licenseType: 'LicenseIncluded'
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: storageredundancy
    isLedgerOn: false
  }

}
