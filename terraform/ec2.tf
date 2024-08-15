resource "aws_instance" "flask_server" {
  ami           = data.aws_ssm_parameter.latest_amazon_linux_ami.value
  instance_type = "t2.micro"

  subnet_id                   = aws_subnet.public_a.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.ec2_sg.name]
  tags = {
    Name = "FlaskServer"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y python3-pip git jq

              # Clone the repository
              git clone https://github.com/kevuyt/portfolio.git /home/ec2-user/portfolio-website
              cd /home/ec2-user/portfolio-website/backend

              # Set up the Python virtual environment
              python3 -m venv venv
              source venv/bin/activate

              # Fetch RDS credentials from Secrets Manager
              secret=$(aws secretsmanager get-secret-value --secret-id rds-credentials --query SecretString --output text)
              username=$(echo $secret | jq -r .username)
              password=$(echo $secret | jq -r .password)

              # Install required Python packages
              pip3 install -r requirements.txt

              # Create environment variables for the Flask app
              export DB_USERNAME=$username
              export DB_PASSWORD=$password
              export DB_HOST="your-rds-endpoint"
              export DB_NAME="portfolio"

              # Start the Flask app
              nohup python3 app.py &

              EOF
}
