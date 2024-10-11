param registryName string = 'mytestacr'
param location string = resourceGroup().location
param sku string = 'Basic'

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: false
  }
}
