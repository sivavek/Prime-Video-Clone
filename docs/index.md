# Proof of Concept: End-to-End CI/CD Pipeline Using GitHub Actions
This project demonstrates a complete CI/CD pipeline orchestrated via GitHub Actions.
Terraform provisions the required AWS infrastructure.
An EC2 instance is configured as a self-hosted GitHub Actions runner.
The application is built using a pipeline script.
Argo CD deploys the application to an EKS cluster.
