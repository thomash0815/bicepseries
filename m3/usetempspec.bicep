
module storageAccountTemplateSpec 'ts:sub-guid/my-testrg/Storage:1.0' = {
  name: 'storageAccountTemplateSpec'
  params: {
    storagePrefix: '001'
  }
}

//alias
//https://learn.microsoft.com/en-us/training/modules/share-bicep-modules-using-private-registries/6-use-module-from-registry


//achtung syntax anders!
module stoModule  'ts/StorageTempSpecs:Storage:1.0' = {
  name: 'stoTempSpecAlias'
  params: {
    storagePrefix: '007'
  }
}


