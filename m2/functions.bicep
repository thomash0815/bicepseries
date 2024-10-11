// build in
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions

//#####################################################################################
//"normale" funktionen

//basic für Arrays / Objekten in bicep: bei neuer Zeile kein Komma
var testString = 'Abc die Katze liegt im Schnee'
var testArray = ['Abc', 'die', 'Katze', 'liegt', 'im', 'Schnee']

var testArray2 = [
  'und'
  'baut'
  'einen'
  'Schneemann'
]

var intArray = [1,2,3,4,5]

output toLower string = toLower(testString)
output toUpper string = toUpper(testString)
output splitArray array = split(testString, ' ')
output indexOf int = indexOf(testString, 'Katze')
output unionArray array = union(testArray, testArray2)
output minInt int = min(intArray)
output maxInt int = max(intArray)

//#####################################################################################
// lampda funktionen

var people = [
  {
    name: 'Anton'
    alter: 9
    hobbies: ['Fussball', 'Schwimmen']
  }
  {
    name: 'Lisa'
    alter: 7
    hobbies: ['Katzen', 'Hunde']
  }
  {
    name: 'Erich'
    alter: 8
    hobbies: ['Lego', 'Playmobil','Katzen']
  }
]

output olderKids array = filter(people, ppl => ppl.alter >=8)
output mapObject array = map(range(0, length(people)), i => {
  index: i
  wer: people[i].name
  spruch: 'Hoi, ${people[i].name}!'
})

//#####################################################################################
//cidr
//https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-cidr#parsecidr


output gensubnets array = [for i in range(0, 5): cidrSubnet('10.140.0.0/16', 24, i)]
output v4info object = parseCidr('10.140.0.0/16')

//#####################################################################################
//date funcs
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-date#datetimeadd

//budget alerts oder kv secrets, Achtung!!! utcnow nur im parameter context möglich
param startDate string = '${utcNow('yyyy-MM')}-01'

output startDate string = startDate
output endDate string = dateTimeAdd(startDate, 'P5Y')

//#####################################################################################
// scope functions
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-scope#subscription


output tenantOutput object = tenant()
output subscriptionOutput object = subscription()
output resourceGroupOutput object = resourceGroup()
//output specificRG object = resourceGroup(subscriptionId, resourceGroupName)

output checkSubs bool = subscription().displayName == 'Visual Studio Enterprise-Abonnement'
output doDeploy bool = startsWith(subscription().displayName, 'prod')

var sub = subscription().displayName

param showEnvironment string = '123'
param location string = 'switzerlandnorth'
param keyvaultName string = 'mykeyvault...'
param principalId string = 'xyz'

output env string = showEnvironment

//#####################################################################################
// eigene

func buildUrl(https bool, hostname string, path string) string => '${https ? 'https' : 'http'}://${hostname}${empty(path) ? '' : '/${path}'}'


func getStorageSKU(environment string) string => '${environment == 'development' ? 'Standard_LRS' : environment == 'testing' ? 'Standard_GRS' : 'Standard_RAGZRS'}'

// Definition der Funktion
@export()
func getStoSKU(env string) string => 
'${env == 'dev' ? 'Standard_LRS' : env == 'test' ? 'Standard_GRS' : 'Standard_GZRS'}'

output storageSKU string = getStoSKU('development')
output storageSKU2 string = getStorageSKU('testing')
output storageSKU3 string = getStorageSKU('production')


//#####################################################################################
//types
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/user-defined-data-types
// -> entweder type keyword in im parameter kontext -> typ frei definierbar

type myStringLiteralType = 'bicep' | 'arm' | 'azure'

type obj = {
  level: 'bronze' | 'silver' | 'gold'
}

output typeOutput myStringLiteralType = 'arm'

output objOutput obj = {
  level: 'bronze'
}

//#####################################################################################
// key vault

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: keyvaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    createMode: 'default'

    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
    sku: {
      family: 'A'
      name: 'standard'
    }

  }
}

param pwd string = 'abc'

resource keyVaultSecretUserRoleRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'guid here'
}

//https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-rbac
@description('Grant the app service identity with key vault secret user role permissions over the key vault. This allows reading secret contents')
resource keyVaultSecretUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  scope: keyVault
  name: guid(resourceGroup().id, principalId, keyVaultSecretUserRoleRoleDefinition.id)
  properties: {
    roleDefinitionId: keyVaultSecretUserRoleRoleDefinition.id
    principalId: principalId
    principalType: 'User'
  }
}

//output test object = keyVault.getSecret('pwd')
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-resource#getsecret
output test string = pwd

// 3.Option für child ressources -> name zusammensetzen
resource mySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyvaultName}/test-secret'  // Two segments
  properties: {
    value: '1234'
  }
}


