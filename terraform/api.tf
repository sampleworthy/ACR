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
  features {}
}

#ResourceGroup
resource "azurerm_resource_group" "apis" {
  name        = "apim"
  location    = "East US"
}

#AppInsights
resource "azurerm_application_insights" "appInsights" {
  name                = "apminsights"
  location            = azurerm_resource_group.apis.location
  resource_group_name = azurerm_resource_group.apis.name
  application_type    = "web"
}

#API management information
resource "azurerm_api_management" "apim" {
  name                = "apimtestingjaydx"
  location            = azurerm_resource_group.apis.location
  resource_group_name = azurerm_resource_group.apis.name
  publisher_name      = "Justin Laws"
  publisher_email     = "jayapimtesting@outlook.com"
  sku_name            = "Developer_1"
}

#APIs
resource "azurerm_api_management_api" "conferenceApi" {
    name                = var.apis.conferenceApi.name
    resource_group_name = azurerm_resource_group.apis.name
    api_management_name = azurerm_api_management.apim.name
    revision            = "1"
    display_name        = "conference API"
    path                = "conferences"
    protocols           = ["https", "http"]
    import {
        content_format = "swagger-link-json"
        content_value  = "http://conferenceapi.azurewebsites.net/?format=json"
    }
}

#AppInsightsLogger
resource "azurerm_api_management_logger" "logger" {
    name                = "appInsightsLogger"
    api_management_name = azurerm_api_management.apim.name
    resource_group_name = azurerm_resource_group.apis.name
    application_insights {
        instrumentation_key = azurerm_application_insights.appInsights.instrumentation_key
    }
}

#API Diagnostic
resource "azurerm_api_management_api_diagnostic" "apiDiagnostics" {
    for_each = var.apis
    resource_group_name = azurerm_resource_group.apis.name
    api_management_name = azurerm_api_management.apim.name
    api_name = each.value.name
    api_management_logger_id = azurerm_api_management_logger.logger.id
    identifier = "applicationinsights"
}

#API Policy var.apim_policies_path
resource "azurerm_api_management_named_value" "policies" {
  name                = "policies"
  resource_group_name = azurerm_resource_group.apis.name
  api_management_name = azurerm_api_management.apim.name
  display_name        = "ExampleProperty"
  value               = "Example Value"
}

resource "azurerm_api_management_policy" "policies" {
  api_management_id = azurerm_api_management.apim.id
  xml_content       = file(var.apim_policies_path)
}

#Creat API Products
resource "azurerm_api_management_product" "product" {
  product_id            = "test-product"
  resource_group_name   = azurerm_resource_group.apis.name
  api_management_name   = azurerm_api_management.apim.name
  display_name          = "test Product"
  subscription_required = true
  approval_required     = false
  published             = true
}
