resource "tencentcloud_vpc" "main" {
  name         = "miao.vpc.main"
  cidr_block   = "10.10.0.0/16"
  is_multicast = true

  tags = {
    "miao.workspace" = "workspace_ai"
  }
}

# vpc  have a default tencentcloud_route_table , so , dont create it

resource "tencentcloud_subnet" "sub" {
  vpc_id            = tencentcloud_vpc.main.id
  name              = "tf-as-subnet"
  cidr_block        = "10.10.30.0/24"
  availability_zone = "ap-guangzhou-3"
}
resource "tencentcloud_subnet" "sub2" {
  vpc_id            = tencentcloud_vpc.main.id
  name              = "tf-as-subnet"
  cidr_block        = "10.10.31.0/24"
  availability_zone = "ap-guangzhou-3"
}

resource "tencentcloud_eks_cluster" "foo" {
  cluster_name = "tf-test-eks"
  k8s_version = "1.24.4"
  vpc_id = tencentcloud_vpc.main.id
  subnet_ids = [
    tencentcloud_subnet.sub.id,
    tencentcloud_subnet.sub2.id,
  ]
  cluster_desc = "test eks cluster created by terraform"
  service_subnet_id =     tencentcloud_subnet.sub.id
  enable_vpc_core_dns = true
  need_delete_cbs = true
  tags = {
    hello = "world"
  }
}


data "tencentcloud_images" "my_favorite_image" {
  image_type       = ["PUBLIC_IMAGE"]
  image_id = "img-eb30mz89" # TencentOS Server 3.1 (TK4)
}

data "tencentcloud_instance_types" "my_favorite_instance_types" {
  filter {
    name   = "instance-family"
    values = ["S5"]
    # availability_zone = "ap-guangzhou-3"

  }

  cpu_core_count   = 2
  exclude_sold_out = true
}
# output "example" {
#   value = data.tencentcloud_instance_types.my_favorite_instance_types
# }


// Create a POSTPAID_BY_HOUR CVM instance
resource "tencentcloud_instance" "cvm_postpaid" {
  instance_name     = "cvm_postpaid"
  availability_zone = "ap-guangzhou-3"
  image_id          = data.tencentcloud_images.my_favorite_image.images.0.image_id
  instance_type     = data.tencentcloud_instance_types.my_favorite_instance_types.instance_types.0.instance_type
  system_disk_type  = "CLOUD_PREMIUM"
  system_disk_size  = 20
  hostname          = "user"
  project_id        = 0
  vpc_id            = tencentcloud_vpc.main.id
  subnet_id         = tencentcloud_subnet.sub.id

  tags = {
    tagKey = "tagValue"
  }
}
