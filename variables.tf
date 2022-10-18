variable "region" {
    type = string
    default = "europe-west2"
}
variable "project" {
    type = string
}
variable "credentials_file" {
    type = string
}
variable "user" {
    type = string
}
variable "email" {
    type = string
}
variable "privatekeypath" {
    type = string
    default = "~/.ssh/id_rsa"
}
variable "publickeypath" {
    type = string
    default = "~/.ssh/id_rsa.pub"
}
