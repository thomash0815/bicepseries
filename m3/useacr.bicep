
module stoModule 'br:myacr.azurecr.io/bicep/modules/storage:v1' = {
  name: 'storage'
  params: {
    storagePrefix: 'sto001'
  }
}

//alias
//https://learn.microsoft.com/en-us/training/modules/share-bicep-modules-using-private-registries/6-use-module-from-registry


//achtung syntax anders!
module stoModule2 'br/MyBicepRegistry:bicep/modules/storage:v1' = {
  name: 'storage2'
  params: {
    storagePrefix: 'sto002'
  }
}

module stoModule3 'br/MyStorageModule:storage:v1' = {
  name: 'storage3'
  params: {
    storagePrefix: 'sto003'
  }
}
