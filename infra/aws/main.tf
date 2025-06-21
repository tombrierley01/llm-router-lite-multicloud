module "network" {
  source = "./network"
}

module "iam" {
  source = "./iam"
}

module "cloudwatch" {
  source = "./cloudwatch"
}

module "secrets" {
  source         = "./secrets"
  openai_api_key = var.openai_api_key
}

module "alb" {
  source            = "./alb"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.network.alb_sg_id
}

module "ecs" {
  source             = "./ecs"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  task_exec_role_arn = module.iam.task_exec_role_arn
  task_role_arn      = module.iam.task_role_arn
  log_group_name     = module.cloudwatch.log_group_name
  tg_arn             = module.alb.target_group_arn
  openai_secret_arn  = module.secrets.openai_secret_arn
  ecs_sg_id          = module.network.ecs_sg_id
}
