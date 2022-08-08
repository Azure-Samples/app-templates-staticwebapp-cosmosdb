@description('First part of the resource name')
param nameprefix string

@description('Azure region for resources')
param location string = resourceGroup().location

resource storageappdata 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${nameprefix}appstor'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: true
    supportsHttpsTrafficOnly: true
  }
}

output staticWebsiteUrl string = replace(replace(storageappdata.properties.primaryEndpoints.web, 'https://',''), '/', '')
output storageAccountName string = storageappdata.name
