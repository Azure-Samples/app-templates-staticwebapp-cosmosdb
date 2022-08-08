@description('First part of the resource name')
param nameprefix string

@description('The base URL of the API, without https://')
param apiUrl string

@description('The base URL of the website, without https://')
param webUrl string

resource frontdoor 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: '${nameprefix}afd'
  location: 'Global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  properties: {
    originResponseTimeoutSeconds: 60
  }
}

resource afdendpoint 'Microsoft.Cdn/profiles/afdendpoints@2021-06-01' = {
  parent: frontdoor
  name: nameprefix
  location: 'Global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource afdorigingroup_api 'Microsoft.Cdn/profiles/origingroups@2021-06-01' = {
  parent: frontdoor
  name: 'origingroup-api'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    sessionAffinityState: 'Disabled'
  }
}

resource afdorigingroup_web 'Microsoft.Cdn/profiles/origingroups@2021-06-01' = {
  parent: frontdoor
  name: 'origingroup-web'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    sessionAffinityState: 'Disabled'
  }
}

resource afdorigin_api 'Microsoft.Cdn/profiles/origingroups/origins@2021-06-01' = {
  parent: afdorigingroup_api
  name: 'origin-api'
  properties: {
    hostName: apiUrl
    httpPort: 80
    httpsPort: 443
    originHostHeader: apiUrl
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
}

resource afdorigin_web 'Microsoft.Cdn/profiles/origingroups/origins@2021-06-01' = {
  parent: afdorigingroup_web
  name: 'origin-web'
  properties: {
    hostName: webUrl
    httpPort: 80
    httpsPort: 443
    originHostHeader: webUrl
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
}

resource afdroute_api 'Microsoft.Cdn/profiles/afdendpoints/routes@2021-06-01' = {
  parent: afdendpoint
  name: 'route-api'
  properties: {
    customDomains: []
    originGroup: {
      id: afdorigingroup_api.id
    }
    ruleSets: []
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/api/*'
    ]
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
}

resource afdroute_web 'Microsoft.Cdn/profiles/afdendpoints/routes@2021-06-01' = {
  parent: afdendpoint
  name: 'route-web'
  properties: {
    customDomains: []
    originGroup: {
      id: afdorigingroup_web.id
    }
    originPath: '/'
    ruleSets: []
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
}

output frontDoorEndpointHostName string = afdendpoint.properties.hostName
