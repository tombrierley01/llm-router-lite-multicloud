module "network" {
  source = "./network"
}

module "iam" {
  source                        = "./iam"
  openai_secret_arn             = module.secrets.openai_secret_arn
  openai_project_id_secret_arn  = module.secrets.openai_project_id_secret_arn
  litellm_master_key_secret_arn = module.secrets.litellm_master_key_secret_arn
  database_url_secret_arn       = module.secrets.database_url_secret_arn
  jwt_secret_secret_arn         = module.secrets.jwt_secret_secret_arn
}

module "cloudwatch" {
  source = "./cloudwatch"
}

module "secrets" {
  source             = "./secrets"
  openai_api_key     = var.openai_api_key
  openai_project_id  = var.openai_project_id
  LITELLM_MASTER_KEY = var.LITELLM_MASTER_KEY
  DATABASE_URL       = var.DATABASE_URL
  JWT_SECRET         = var.JWT_SECRET
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
  ecs_sg_id          = module.network.ecs_sg_id

  openai_secret_arn             = module.secrets.openai_secret_arn
  openai_project_id_secret_arn  = module.secrets.openai_project_id_secret_arn
  litellm_master_key_secret_arn = module.secrets.litellm_master_key_secret_arn
  database_url_secret_arn       = module.secrets.database_url_secret_arn
  container_image               = var.container_image
  jwt_secret_secret_arn         = module.secrets.jwt_secret_secret_arn
}
