terraform {
  required_providers {
    tencentcloud = {
      source = "tencentcloudstack/tencentcloud"
      # 通过version指定版本
      # version = ">=1.60.18"
    }
  }
}

provider "tencentcloud" {
  region = "ap-guangzhou"

  # secret from env
  # export TENCENTCLOUD_SECRET_ID=my-secret-id
  # export TENCENTCLOUD_SECRET_KEY=my-secret-key
  # secret_id = "my-secret-id"
  # secret_key = "my-secret-key"
}