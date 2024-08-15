# Generate a random password for the RDS instance
resource "random_password" "rds_password" {
  length  = 16
  special = true
}

# Store the generated credentials in AWS Secrets Manager
resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "rds-credentials"
}

resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = "kevalkataria"
    password = random_password.rds_password.result
  })
}

# Create the RDS instance with generated credentials
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  db_name              = "portfolio"
  username             = "kevalkataria"
  password             = random_password.rds_password.result
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  parameter_group_name = "default.mysql5.7"
  publicly_accessible  = false
  multi_az             = false

  tags = {
    Name = "portfolio-db"
  }
}
