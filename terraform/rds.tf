# Generate a random password for the RDS instance
resource "random_password" "rds_password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "rds_credential" {
  name = "rds-credential"
}

resource "aws_secretsmanager_secret_version" "rds_credential_version" {
  secret_id     = aws_secretsmanager_secret.rds_credential.id
  secret_string = jsonencode({
    username = "kevalkataria"
    password = random_password.rds_password.result
  })
}

resource "aws_db_subnet_group" "default" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.34"
  instance_class       = "db.t3.micro"
  db_name              = "portfolio"
  username             = "kevalkataria"
  password             = random_password.rds_password.result
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  parameter_group_name = "default.mysql8.0"
  publicly_accessible  = false
  multi_az             = false

  tags = {
    Name = "portfolio-db"
  }
}