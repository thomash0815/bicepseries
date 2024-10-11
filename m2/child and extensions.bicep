//1. childs
// https://learn.microsoft.com/en-us/training/modules/child-extension-bicep-templates/3-define-child-resources

//entweder nested oder parent reference oder 3. per Name (siehe KV / functions)
// oder 3 per full ref: https://ochzhen.com/blog/child-resources-in-azure-bicep#outside-parent-without-parent-property

// bei parent braucht es api version, bei nested nicht

param location string = 'switzerlandnorth'
param storageAccountName string = 'mystoname'


//sto all in one: (nested)
resource storageAllinOne 'Microsoft.Storage/storageAccounts@2021-06-01' = {

  name: 'stoabc123'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }

  resource blobServices 'blobServices' = {
    name: 'default'
    properties: {
      
    }
    resource blobContainers 'containers' = {
      name: 'container1'
      properties: {
        publicAccess: 'None'
      }
    }
  }
}

output blobRetention int = storageAllinOne::blobServices.properties.deleteRetentionPolicy.days
output blobContainerName string = storageAllinOne::blobServices::blobContainers.name

//2. das gleiche, aber mit parent reference

resource storageParent 'Microsoft.Storage/storageAccounts@2021-06-01' = {

  name: 'mystoname2'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}
resource blobServices2 'Microsoft.Storage/storageAccounts/blobServices@2019-06-01' = {
  name: 'default'
  parent: storageParent
}

resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: 'container1'
  parent: blobServices2
  properties: {
    publicAccess: 'None'
  }
}

// 3. existing

resource storageParent2 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: 'mystoname2'
  //scope: resourceGroup('rg-other')
}

output stoRessourceId string = storageParent2.id
output stoKey1 string = storageParent2.listKeys().keys[0].value
output usedLocation string = storageParent2.location


resource blobServices3 'Microsoft.Storage/storageAccounts/blobServices@2019-06-01' existing = {
  name: 'default'
  parent: storageParent2
}

resource blobContainers2 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: 'container2'
  parent: blobServices3
  properties: {
    publicAccess: 'None'
  }
}

resource blobContainers3 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: 'mystoname2/default/container3'
  //parent: blobServices3
  properties: {
    publicAccess: 'None'
  }
}


//law
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'myLogAnalyticsWorkspace'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

//2. extensions


resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: storageAccountName

  resource blobService 'blobServices' existing = {
    name: 'default'
  }
}

resource storageAccountBlobDiagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  scope: storageAccount::blobService
  name: 'myStoDiagnosticSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
  }
}

resource stolock 'Microsoft.Authorization/locks@2017-04-01' = {
  name: 'sto-lock-no-delete'
  properties: {
    level: 'CanNotDelete'
    notes: 'Storage account can not be deleted'
  }
  //extensions braucht die scope() function
  scope: storageAccount
}

resource stolock2 'Microsoft.Authorization/locks@2017-04-01' existing = {
  name: 'sto-lock-no-delete'

  //extensions brauch scope() function
  scope: storageAccount
}





