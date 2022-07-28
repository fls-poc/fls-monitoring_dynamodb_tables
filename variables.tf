variable "context" {
  type    = string
  default = ""
}

variable "china_ext" {
  type        = string
  default     = ""
  description = "Systematical adding of .cn to endpoints located in China"
}

variable "fixed_tags" {
  type        = map(string)
  description = "Fixed tags For all FLS's Projects resources"
}

variable "available_az" {
  type    = list(any)
  default = []
}

variable "policy" {
  type    = string
  default = ""
}

variable "path" {
  type    = string
  default = ""
}

variable "name" {
  type    = string
  default = ""
}

variable "purpose" {
  type    = string
  default = ""
}

variable "application" {
  type    = string
  default = ""
}

variable "base_lambda_repo" {
  type    = string
  default = "Lambda repository to download python files from, including service subdirectory."
}

variable "git_token" {
  type    = string
  default = ""
}

variable "aws_region" {
  type    = string
  default = ""
}

variable "is_dev" {
  type    = bool
  default = true
}

variable "table_hash_key" {
  type    = string
  default = "row_id"
}

variable "table_time_to_live" {
  type    = string
  default = "ttl"
}

variable "account_id" {
  type = string
  default = ""
}

variable "account_name" {
  type = string
  default = ""
}
