variable "apim_policies_path" {
  type        = string
  description = "Path to a file defining the Azure API Management policies in XML"
  default     = "./apim_policies/policies.xml"
}