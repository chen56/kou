resource "tencentcloud_vpc" "main" {
  name         = "younpc.vpc.main"
  cidr_block   = "10.10.0.0/16"
  is_multicast = true

  tags = {
    "younpc.workspace" = "workspace_ai"
  }
}
# vpc  have a default tencentcloud_route_table , so , dont create it

resource "tencentcloud_subnet" "zone_7" {
  vpc_id            = tencentcloud_vpc.main.id
  name              = "younpc.subnet.zone_7"
  cidr_block        = "10.10.70.0/24"
  availability_zone = "ap-guangzhou-7"
}

#################################################################
# 暂时放弃eks
# 1. eks集群创建、销毁需要1m30s
# 2. eks集群的api server 还需要单独开clb，0.2元/小时
# 3. eks在控制台创建一个竞价实例deployment,需要的时间貌似也要几十秒
#################################################################
# resource "tencentcloud_eks_cluster" "foo" {
#   cluster_name = "tf-test-eks"
#   k8s_version = "1.24.4"
#   vpc_id = tencentcloud_vpc.main.id
#   subnet_ids = [
#     tencentcloud_subnet.sub.id,
#     tencentcloud_subnet.sub2.id,
#   ]
#   cluster_desc = "test eks cluster created by terraform"
#   service_subnet_id =     tencentcloud_subnet.sub.id
#   enable_vpc_core_dns = true
#   need_delete_cbs = true
#   tags = {
#     hello = "world"
#   }
# }


data "tencentcloud_images" "my_favorite_image" {
  image_type       = ["PUBLIC_IMAGE"]
  image_id = "img-eb30mz89" # TencentOS Server 3.1 (TK4)
}

# https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/data-sources/instance_types
data "tencentcloud_instance_types" "my_favorite_instance_types" {
  # availability_zone = "ap-guangzhou-3"
  cpu_core_count   = 2
  exclude_sold_out = true
  filter {
    name   = "instance-family"
    values = ["S5"]
  }
  filter {
    name   = "instance-charge-type"
    values = ["SPOTPAID"]
  }
  filter {
    name   = "zone"
    values = ["ap-guangzhou-3"]
  }
}

# output "example" {
#   value = data.tencentcloud_instance_types.my_favorite_instance_types
# }


// Create a POSTPAID_BY_HOUR CVM instance
resource "tencentcloud_instance" "cvm_postpaid" {
  instance_name     = "cvm_postpaid"
  availability_zone = "ap-guangzhou-7"
  image_id          = data.tencentcloud_images.my_favorite_image.images.0.image_id
  instance_type     = data.tencentcloud_instance_types.my_favorite_instance_types.instance_types.0.instance_type

  instance_charge_type = "SPOTPAID"

  system_disk_type  = "CLOUD_PREMIUM"
  system_disk_size  = 20
  hostname          = "user"
  project_id        = 0
  vpc_id            = tencentcloud_vpc.main.id
  subnet_id         = tencentcloud_subnet.zone_7.id

  tags = {
    tagKey = "tagValue"
  }
}
