resource "tencentcloud_vpc" "workspace_ai" {
  name         = "workspace_ai"
  cidr_block   = "10.0.0.0/16"
  is_multicast = true

  tags = {
    "miao.workspace" = "workspace_ai"
  }
}

# vpc  have a default tencentcloud_route_table , so , dont create it