variable "vpc_id" {
  type = string

}
variable "subnet_ids" {
  type = list(any)

}
variable "public_subnet_id" {
  type = string

}
