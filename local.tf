locals {
  project_name = "yourdevops"

  vpc_name = "yourdevops-vpc"
  vpc_cidr = "10.0.0.0/16"
  vpc_az = {
    ap-northeast-1a = "ap-northeast-1a"
    ap-northeast-1c = "ap-northeast-1c"
  }
  private_subnet = {
    ap-northeast-1a = "10.0.1.0/24"
    ap-northeast-1c = "10.0.2.0/24"
  }
  public_subnet = {
    ap-northeast-1a = "10.0.101.0/24"
    ap-northeast-1c = "10.0.102.0/24"
  }
}
