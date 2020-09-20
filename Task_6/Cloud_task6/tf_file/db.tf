provider "aws" {
    region = "ap-south-1"
}
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = ["subnet-0e22a775", "subnet-3d245671"]


  tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_db_instance" "sqldb" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.20"
  instance_class       = "db.t2.micro"
  name                 = "sqldb"
  username             = "shreyas"
  password             = "Shreyas9711"
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  publicly_accessible = true
  iam_database_authentication_enabled = true


tags = {
    Name  = "wordpress_mysql_db"
}
}
output "ip" {
  value = aws_db_instance.sqldb.address

  }
