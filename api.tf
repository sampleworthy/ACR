resource "azurerm_resource_group" "apis" {
  name     = "apis"
  location = "East US"
}

resource "azurerm_application_insights" "appInsights" {
  resource_group_name = azurerm_resource_group.apis.name
  name                = "apm4apim001"
  location            = azurerm_resource_group.apis.location
  application_type    = "web"
}

resource "azurerm_api_management" "apim" {
  sku_name            = "Developer_1"
  resource_group_name = azurerm_resource_group.apis.name
  publisher_name      = "SAS"
  publisher_email     = "Justin.Laws@sas.com"
  name                = "apim11092020"
  location            = azurerm_resource_group.apis.location
}

resource "azurerm_api_management_api" "conferenceApi" {
  revision            = "1"
  resource_group_name = azurerm_resource_group.apis.name
  path                = "conferences"
  name                = var.apis.conferenceApi.name
  display_name        = "conference API"
  api_management_name = azurerm_api_management.apim.name

  import {
    content_value  = "http://conferenceapi.azurewebsites.net/?format=json"
    content_format = "swagger-link-json"
  }

  protocols = [
    "https",
  ]
}

resource "azurerm_api_management_logger" "logger" {
  resource_group_name = azurerm_resource_group.apis.name
  name                = "appInsightsLogger"
  api_management_name = azurerm_api_management.apim.name

  application_insights {
    instrumentation_key = azurerm_application_insights.appInsights.instrumentation_key
  }
}

resource "azurerm_api_management_api_diagnostic" "apiDiagnostics" {
  resource_group_name      = azurerm_resource_group.apis.name
  identifier               = "applicationinsights"
  for_each                 = var.apis
  api_name                 = each.value.name
  api_management_name      = azurerm_api_management.apim.name
  api_management_logger_id = azurerm_api_management_logger.logger.id
}

