variable "apis" {
  type = map
  default = { { "name" = "conference-api"
  } }
}

variable "tags" {
  description = "Default tags to apply to all resources."
  type        = map(any)
}

