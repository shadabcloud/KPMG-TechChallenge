param PLEname string
param location string
param PLEserviceId string
param groupId string
param PLEsubnetId string

resource PLE 'Microsoft.Network/privateEndpoints@2022-11-01' = {
  name: PLEname
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: PLEname
        properties: {
          privateLinkServiceId: PLEserviceId
          groupIds: [
            groupId
          ]
          privateLinkServiceConnectionState: {
             actionsRequired: 'none'
             status: 'Approved'
          }
        }
      }
    ]
    subnet: {
      id: PLEsubnetId
    }
  }
}
