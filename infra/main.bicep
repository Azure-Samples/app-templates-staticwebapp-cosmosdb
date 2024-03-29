targetScope = 'subscription'

@minLength(1)
@maxLength(16)
@description('Prefix for all resources, i.e. {name}storage')
param name string

@minLength(1)
@description('Primary location for all resources')
param location string = deployment().location

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${name}-rg'
  location: location
}

module storage './resources/storage.bicep' = {
  name: '${rg.name}-storage'
  scope: rg
  params: {
    nameprefix: toLower(name)
    location: rg.location
  }
}

module function './resources/function.bicep' = {
  name: '${rg.name}-function'
  scope: rg
  params: {
    nameprefix: toLower(name)
    location: rg.location
  }
  dependsOn: [
    // We need to insert the Cosmos ConnectionString in the function's parameters so it needs to exist first
    cosmosdb
  ]
}

module frontdoor './resources/frontdoor.bicep' = {
  name: '${rg.name}-frontdoor'
  scope: rg
  params: {
    nameprefix: toLower(name)
    apiUrl: function.outputs.functionUrl
    webUrl: storage.outputs.staticWebsiteUrl
  }
}

module cosmosdb './resources/cosmosdb.bicep' = {
  name: '${rg.name}-cosmosdb'
  scope: rg
  params: {
    nameprefix: toLower(name)
    location: rg.location
  }
}
//  Telemetry Deployment
@description('Enable usage and telemetry feedback to Microsoft.')
param enableTelemetry bool = true
var telemetryId = '69ef933a-eff0-450b-8a46-331cf62e160f-staticwa-${location}'
resource telemetrydeployment 'Microsoft.Resources/deployments@2021-04-01' = if (enableTelemetry) {
  name: telemetryId
  location: location
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#'
      contentVersion: '1.0.0.0'
      resources: {}
    }
  }
}
output resource_group_name string = rg.name
output function_name string = function.outputs.functionName
output storage_account_name string = storage.outputs.storageAccountName
output cosmosdb_name string = cosmosdb.outputs.cosmosDBName
output frontdoor_hostname string = frontdoor.outputs.frontDoorEndpointHostName
