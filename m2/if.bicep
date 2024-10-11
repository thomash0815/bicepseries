
param location string = resourceGroup().location

//if

param env string = 'production'

var deployStorage = true

//ternary operator

var stoSKU = env == 'development' ? 'Standard_LRS' : env == 'testing' ? 'Standard_GRS' : 'Standard_RAGZRS'  

var storagePrefix = env == 'development' ? 'dev' : env == 'testing' ? 'test' : 'prod'  

var uniqueStorageName = 'sto${storagePrefix}1234'

resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' = if (deployStorage) {

  name: uniqueStorageName
  location: location
  sku: {
    name: stoSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}


