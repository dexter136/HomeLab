variable "name" {
    type = string
}

variable "pg_pass" {
    type = string
    sensitive = true
}
