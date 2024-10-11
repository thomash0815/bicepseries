
//loops: https://learn.microsoft.com/en-us/training/modules/build-flexible-bicep-templates-conditions-loops/4-use-loops-deploy-resources

param location string = resourceGroup().location


var uniqueStorageName = 'mystoname1234'


resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' = {

  name: uniqueStorageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

// für die functions
output stoKeys object = storage.listKeys()
output stoKey string = storage.listKeys().keys[0].value

output resId string = storage.id

// Create blob service
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2019-06-01' = {
  name: 'default'
  parent: storage
}

var start = 1
var end = 4

// [for i in range(1,4):
resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = [for i in range(1, 3): {
  name: 'container${i}'
  parent: blobServices
  properties: {
    publicAccess: 'None'
  }
}]


var containerNames = ['for1container', 'for2container', 'for3container']

// for each
resource blobContainersFor 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = [for containerName in containerNames: {
  name: containerName
  parent: blobServices
  properties: {
    publicAccess: 'None'
  }
}]

  resource blobContainersForIndex 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = [for (containerName, i) in containerNames: {
    name: '${containerName}indexgleich${i*100}'
    parent: blobServices
    properties: {
      publicAccess: 'None'
    }
  }]

resource blobContainersForIf 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = [for containerName in containerNames: if (containerName == 'for1container') {
  name: '${containerName}ifinloop'
  parent: blobServices
  properties: {
    publicAccess: 'None'
  }
}]

// loops für var creation
var genContainer = [for i in range(1, 10): 'container${i}']

output containerNames array = genContainer
