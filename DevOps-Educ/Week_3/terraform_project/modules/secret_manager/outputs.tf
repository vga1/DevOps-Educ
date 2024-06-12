# modules/secret_manager/outputs.tf

output "secret_arn" {
  value = aws_secretsmanager_secret.my_test_secret.arn
}