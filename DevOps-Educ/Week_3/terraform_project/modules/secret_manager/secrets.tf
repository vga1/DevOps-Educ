# modules/secret_manager/secrets.tf

resource "random_password" "my_test_secret_password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "my_test_secret" {
  name        = "my-test-secret"
  description = "This is my test secret"
}

resource "aws_secretsmanager_secret_version" "my_test_secret_value" {
  secret_id     = aws_secretsmanager_secret.my_test_secret.id
  secret_string = random_password.my_test_secret_password.result
}