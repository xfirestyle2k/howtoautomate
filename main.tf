provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = SDDC-Datacenter
}
data "vsphere_compute_cluster" "cluster" {
  name          = Cluster-1
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_datastore" "datastore" {
  name          = WorkloadDatastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = Compute-ResourcePool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = sddc-cgw-network-1
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_content_library" "subscribedlibrary_terraform" {
  name            = "New Subscribed Library by Terraform"
  storage_backing = [data.vsphere_datastore.datastore.id]
  description     = "New Subscribed Library by Terraform"
  subscription {
    subscription_url      = "https://s3-us-west-2.amazonaws.com/s3-vmc-iso/lib.json"
    authentication_method = "NONE"
    automatic_sync        = true
    on_demand             = false
  }
}

data "vsphere_content_library_item" "library_item_photon" {
  depends_on = [time_sleep.wait_30_seconds]
  name       = "Photon"
  library_id = vsphere_content_library.subscribedlibrary_terraform.id
  type       = "OVA"
}

resource "vsphere_virtual_machine" "vm_terraform_from_cl" {
  name             = "terraform"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = "Workloads"

  num_cpus = 4
  memory   = 2048
  guest_id = "other3xLinux64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }
  disk {
    label            = "disk0"
    size             = 20
    thin_provisioned = true
  }
  clone {
    template_uuid = data.vsphere_content_library_item.library_item_photon.id
    customize {
      linux_options {
        host_name = var.VMName
        domain    = var.VMDomain
      }
      network_interface {}
    }
  }
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [vsphere_content_library.subscribedlibrary_terraform]
  create_duration = "30s"
}