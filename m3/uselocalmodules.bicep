//deploy from files or normal repo

param location string = 'northeurope'

// module storage '../modul1/storage.bicep' = {
//   name: 'storage'
//   params: {
//     storagePrefix: 'sto007'
//     location: location
//   }
// }

//mit scope
module storage2 '../modul1/storage.bicep' = {
  name: 'storage'
  scope: resourceGroup('test')
  params: {
    storagePrefix: 'sto008'
    location: location
  }
}

var stoPrefixes = ['001', '002', '003']

//per loop
//bei Schleifen muss durch name oder scope Eindeutigkeit gewährleistet sein
module storage3 '../modul1/storage.bicep' = [
  for prefix in stoPrefixes: {
    name: 'storageFor${prefix}'
    params: {
      storagePrefix: prefix
      location: location
    }
  }
]

//subs
module resoureGroups 'modules/resourcegroup.bicep' = [for sub in subscriptionsToUse: {
  scope: subscription(sub)
  name: 'resource-group'
  params: {
    resourceGroupName: 'rg-monitoring'
  }
}]


//if
module expressroute_alerts 'modules/expressroute-alerts.bicep' = if (tenantInfo.displayName == 'Production Tenant') {
  name: 'expressroute-alerts'
  params: {
    ag_id: ag.outputs.ActionGroup_id
  }
}
