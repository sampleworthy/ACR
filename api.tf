# Terraform version 3.52.0
# variables

variable "apis" {
   type = map
  default = {
      conferenceApi = {
          name = "conference-api"
      }
  }
}

provider "azurerm" {
  version = "3.52.0"
  features {}
}
#ResourceGroup
resource "azurerm_resource_group" "apis" {
  name        = "apis"
  location    = "East US"
}

#AppInsights
resource "azurerm_application_insights" "appInsights" {
  name                = "apm4apim001"
  location            = azurerm_resource_group.apis.location
  resource_group_name = azurerm_resource_group.apis.name
  application_type    = "web"
}

#API managementt information
resource "azurerm_api_management" "apim" {
  name                                 = "apimtestingjay"
  location                             = azurerm_resource_group.apis.location
  resource_group_name     = azurerm_resource_group.apis.name
  publisher_name                = "SAS"
  publisher_email                = "Justin.Laws@sas.com"
  sku_name                          = "Developer_1"
}

#APIs
resource "azurerm_api_management_api" "conferenceApi" {
    name  = var.apis.conferenceApi.name
    resource_group_name = azurerm_resource_group.apis.name
    api_management_name = azurerm_api_management.apim.name
    revision  = "1"
    display_name = "conference API"
    path = "conferences"
    protocols = ["https", "http"]
    # service_url = "http://conferenceapi.azurewebsites.net"
    import {
        content_format = "swagger-link-json"
        content_value  = "http://conferenceapi.azurewebsites.net/?format=json"
    }
}

#AppInsightsLogger
resource "azurerm_api_management_logger" "logger" {
    name  = "appInsightsLogger"
    api_management_name = azurerm_api_management.apim.name
    resource_group_name  = azurerm_resource_group.apis.name
    application_insights {
        instrumentation_key = azurerm_application_insights.appInsights.instrumentation_key
    }
}

#API Diagnostic
resource "azurerm_api_management_api_diagnostic" "apiDiagnostics" {
    for_each = var.apis
        resource_group_name = azurerm_resource_group.apis.name
        api_management_name  = azurerm_api_management.apim.name
        api_name = each.value.name
        api_management_logger_id = azurerm_api_management_logger.logger.id
        identifier = "applicationinsights"
}

#API Policy #var.apim_policies_path
#resource "azurerm_api_management_named_value" "example" {
#  name                = "example-apimg"
 # resource_group_name = azurerm_resource_group.example.name
 # api_management_name = azurerm_api_management.example.name
  #display_name        = "ExampleProperty"
  #value               = "Example Value"
#}

#resource "azurerm_api_management_policy" "example" {
  #api_management_id = azurerm_api_management.example.id
  #xml_content       = file(var.apim_policies_path)
#}

