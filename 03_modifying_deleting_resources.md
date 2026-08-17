# Modifying and deleting resources

A continuación se muestra que ocurre si se modifican o eliminan recursos.

## Modificar recursos

Tomamos nuestro archivo main.tf escrito en la sección anterior y cambiamos los tags:

```terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "us-west-2"
  profile = "default"
}

# Create a VPC
resource "aws_instance" "mi-example-instance" {
  ami           = "ami-02167eae61967e403"
  instance_type = "t2.nano"

  tags = {
    Name = "HelloWorld",
    Category = "TestResource",
  }
}
```

Si le doy a terraform plan me mostrará que actualizará recursos:

```shell
# aws_instance.mi-example-instance will be updated in-place
  ~ resource "aws_instance" "mi-example-instance" {
        id                                   = "i-081f621cc594e0970"
      ~ tags                                 = {
          + "Category" = "TestResource"
            "Name"     = "HelloWorld"
        }
      ~ tags_all                             = {
          + "Category" = "TestResource"
            # (1 unchanged element hidden)
        }
        # (39 unchanged attributes hidden)

        # (9 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

## Eliminar recursos

Hay dos formas de eliminar recursos.

La primera consiste en eliminar todos los recursos creados en mi main.tf:

```shell
terraform destroy
```

Y en la segunda puedo eliminar un recurso directamente en mi main.tf (por ejemplo una instancia de EC2) y luego aplicar los cambios

```shell
terraform apply
```