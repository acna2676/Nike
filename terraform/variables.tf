variable "vpc_cidr" {
    description = "CIDR Block of VPC"
    type        = string
    default     = "172.26.10.0/24"
}
variable "app_name" {
    description = "app_name"
    type        = string
    default     = "Nike"
}
