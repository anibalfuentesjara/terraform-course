# Referencing resources

Si tenemos un recurso que necesita referenciar a otro recurso lo podemos hacer con la siguiente sintaxis:

```terraform
resource "aws_vpc" "production-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "subnet-1" {
  #referencia al id de la vpc
  vpc_id     = aws_vpc.production-vpc.id 
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet-1"
  }
}
```