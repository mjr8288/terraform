variable "sg_ports" {
  type=list(number)
  default=[80,443,22,8200,8201,8300,9200,9500]
}

locals {
  common_tags={
    Name="Provisioners"
  }
}

