// https://learn.microsoft.com/en-us/training/modules/migrate-azure-resources-bicep/2-convert-migrate-resources-bicep-file
//prozess: https://learn.microsoft.com/en-us/training/modules/migrate-azure-resources-bicep/8-workflow-migrate-resources-bicep

import * as myTypes from '../../Monitoring/modules/testparams.bicep'
import * as myFuncs from 'functions.bicep'

var stosku = myFuncs.getStoSKU('dev')

param storageAccountConfig myTypes.storageProperties = {
  name: 'mystorage'
  sku: 'Standard_GRS'
}
