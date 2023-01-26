resource "aws_db_instance" "example" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.22"
  instance_class       = "db.t2.micro"
  name                 = "example"
  username             = "example_user"
  password             = "example_password"
  publicly_accessible  = true
  deletion_protection  = false
  skip_final_snapshot  = true
  backup_retention_period= 0
  auto_minor_version_upgrade= true
}
