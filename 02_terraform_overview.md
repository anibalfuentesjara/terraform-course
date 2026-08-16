# Terraform overview

Terraform está escrito en un lenguaje llamado `hashicorp configuration language` y usan la extensión `.tf`

Vamos a partir creando un archivo `main.tf`.

Lo primero que uno debe configurar en el archivo son los providers, que le indican a terraform que APIs debe utilizar dependiendo de la integración a implementar. Para ver la lista de providers se puede consultar el sitio web:

https://registry.terraform.io/browse/providers


Dentro de la página de los providers buscamos el nuestro, en nuestro caso AWS. Dentro del provider se provee el código necesario para incorporarlo en nuestro proyecto con terraform. Ej:

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
  region = "us-west-2"
  profile = "default"
}
```

La sintaxis que se utilizará posteriormente para crear recursos es la siguiente:

```terraform
resource "<provider>_<resource_type>" "<resource_name>" {
  # key-value pairs for config options
  key = value
  key2 = value2
}
```

Donde provider sería aws, resource_type sería el recurso de aws que queremos manejar, resource_name es un nombre interno del recurso para terraform (no visible para el provider) y luego se entregan configuraciones en key-value pairs.

Para configurar recursos de nuestro provider AWS (https://registry.terraform.io/providers/hashicorp/aws/latest/docs) podemos buscar el recurso en la misma web, por ejemplo, para configurar una instancia de EC2 buscamos el recurso aws_instance en el menu EC2 (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).

Se muestra a continuación el mínimo código necesario para crear la instancia. En él se utiliza un tipo de instancia t2.nano (pequeña y barata) y el ami se asigna a un OS ubuntu 26

```terraform
resource "aws_instance" "mi-example-instance" {
  ami           = "ami-02167eae61967e403"
  instance_type = "t2.nano"

  tags = {
    Name = "HelloWorld"
  }
}
```

Finalmente, nuestro archivo `main.tf` se verá así:

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
    Name = "HelloWorld"
  }
}
```

Para poder ejecutar el código y hacer deploy de mis recursos en la nube debo inicializar terraform para que descargue los providers necesarios.

```shell
terraform init
```

Luego, puedo ver el plan que ejecutará terraform sin que haga ningún cambio aún (dry run):

```shell
terraform plan
```

Y si estoy de acuerdo con el plan, puedo desplegar los recursos y aplicar el plan

```shell
terraform apply
```

