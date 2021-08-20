variable "data_center" {
  }

variable "cluster" {
  }

variable "workload_datastore" {
  }

variable "compute_pool" {
  }

variable "network" {
  }


variable "vsphere_user" {
}
variable "vsphere_password" {
}
variable "vsphere_server" {
}

variable "VMName" {
  default = "Photon"
}

variable "VMDomain" {
  default = "vmc.local"
}

variable "contentLibraryImageURL" {
  default = "https://s3-us-west-2.amazonaws.com/s3-vmc-iso/lib.json"
}