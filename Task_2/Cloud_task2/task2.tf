

### provider and profile ###

provider "aws" {
  region = "ap-south-1"
}

### Security groups for task ###

resource "aws_security_group" "my_security_group" {
  name        = "shrisecurity"
  description = "Allow TCP"
  vpc_id      = "vpc-cf0feba4"

  ingress {
    description = "Lauch-Wizard-Created"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    description = "Lauch-Wizard-Created"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    description = "Lauch-Wizard-Created"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow TCP"
  } 
}


### Creating the EC2-Instance ###

resource "aws_instance" "web1" {
  key_name      = "task1"
  ami           = "ami-0732b62d310b80e97"
  instance_type = "t2.micro"
  
  security_groups = [ "shrisecurity" ]
  
 connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("/home/shri/Downloads/task1.pem")
    host     = aws_instance.web1.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }


tags = {
    Name = "MyTerraformOS"
  }
}

# download images from github
resource "null_resource" "image" {
  depends_on = [null_resource.imagedestroy]
  provisioner "local-exec" {
     command = " git clone https://github.com/B-Shreyas/multicloud.git images"
     }
}
resource "null_resource" "imagedestroy" {
  provisioner "local-exec" {
     
     command = " rm -rf images"
     
  }
}

### creating EBS Volume of size 1 ###


resource "aws_efs_file_system" "myefs" {
  creation_token = "myefs"
  performance_mode = "generalPurpose"

  tags = {
    Name = "myefs1"
  }
}

resource "aws_efs_mount_target" "myefs-mount" {
  file_system_id = aws_efs_file_system.myefs.id
  subnet_id = "subnet-0e22a775"
  security_groups = [ aws_security_group.my_security_group.id ]
}



resource "null_resource" "nulllocal2"  {
  provisioner "local-exec" {
      command = "echo  ${aws_instance.web1.public_ip} > publicip.txt"
    }
}



resource "aws_s3_bucket" "mytaskbucketshreyas24" {
  bucket = "mytaskbucketshreyas24"
  acl = "public-read"
 
  tags = {
    Name  = "My-task-bucket"
    Environment = "Dev"
  }
}

###  Bucket object and uploading an Image ###

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.mytaskbucketshreyas24.bucket
  acl = "public-read"
  key    = "Shreyas.jpeg"
  source = "images/Shreyas.jpeg"
depends_on=[aws_s3_bucket.mytaskbucketshreyas24,null_resource.image]

}



### make cloudfront distribution ###

resource "aws_cloudfront_distribution" "my_distributiontask" {
    origin {
         domain_name = "${aws_s3_bucket.mytaskbucketshreyas24.bucket_regional_domain_name}"
         origin_id   = "${aws_s3_bucket.mytaskbucketshreyas24.id}"
 
        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
        }
    }
    
    default_root_object = "Shreyas.jpeg"
    enabled = true

    custom_error_response {
        error_caching_min_ttl = 3000
        error_code = 404
        response_code = 200
        response_page_path = "/index.php"
    }

default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.mytaskbucketshreyas24.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE","IN"]
    }
  }

    # SSL certificate for the service.
    viewer_certificate {
        cloudfront_default_certificate = true
    }
 depends_on=[aws_s3_bucket.mytaskbucketshreyas24]
}
resource "null_resource" "nullremote"  {
depends_on = [  aws_efs_mount_target.myefs-mount,aws_cloudfront_distribution.my_distributiontask]
    connection {
        type    = "ssh"
        user    = "ec2-user"
        host    = aws_instanc.web1.public_ip
        port    = 22
        private_key = file("/home/shri/Downloads/task1.pem")
    }
}


### EC2 attaching ###

resource "null_resource" "nullremote3"  {

depends_on = [
    aws_efs_mount_target.myefs-mount
  ]
 connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("/home/shri/Downloads/task1.pem")
    host     = aws_instance.web1.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdf",
      "sudo mount  /dev/xvdf  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/B-Shreyas/multicloud.git /var/www/html/",
      "sudo su << EOF",
            "echo \"${aws_cloudfront_distribution.my_distributiontask.domain_name}\" >> /var/www/html/myinstanceip.txt",
            "EOF",
      "sudo systemctl restart httpd"
    ]
  }
}
# open the website in chrome
resource "null_resource" "nulllocal1"  {
depends_on = [
    null_resource.nullremote3,
  ]
  provisioner "local-exec" {
      command = "google-chrome ${aws_instance.web1.public_ip}"
         }
}





