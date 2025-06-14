# LLM Router – Multi-Cloud AI Infra

A cost-aware, multi-cloud router for LLM workloads using LiteLLM, deployed on AWS and GCP.

### Features
- Routes between OpenAI, Bedrock, and Gemini
- Token + cost tracking
- Quota enforcement
- CI/CD with GitHub Actions
- Terraform-based infra

### Stack
- Python + FastAPI + LiteLLM
- AWS ECS, GCP Cloud Run
- Terraform, GitHub Actions

Work in progress

## TODO

- Add FastAPI wrapper around LiteLLM
- Add AWS ECS + Bedrock Terraform
- Add GCP Cloud Run Terraform
- Implement cost logging per model
- Add fallback logic between providers
- Add API key-based request auth
- Create YouTube video
