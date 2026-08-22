# Curso de terraform

## Índice

- [1. Instalación de terraform](#1-instalación-de-terraform)
  - [Windows](#windows)
  - [VSCode](#vscode)
- [2. Terraform overview](#2-terraform-overview)
- [3. Modifying and deleting resources](#3-modifying-and-deleting-resources)
  - [Modificar recursos](#modificar-recursos)
  - [Eliminar recursos](#eliminar-recursos)
- [4. Referencing resources](#4-referencing-resources)
- [5. Terraform files](#5-terraform-files)
- [6. Terraform commands](#6-terraform-commands)
- [7. Terraform output](#7-terraform-output)
- [8. Target resources](#8-target-resources)
- [9. Terraform variables](#9-terraform-variables)
  - [terraform.tfvars](#terraformtfvars)



## 1. Instalación de terraform

### Windows

1. Descargar el ejecutable desde la página https://developer.hashicorp.com/terraform/install
2. Poner el ejecutable en alguna carpeta, ejemplo: `C:\Program Files (x86)\Terraform`
3. Agregar la ruta a las variables de entorno (env), para ello buscar las variables de entorno en la barra, luego en variables de sistema buscar `Path`, agregar posteriormente la ruta del ejecutable.
4. Abrir una terminal (por ejemplo powershell)
 y ejecutar `terraform -v` . Debiese mostrar la versión, ej: 

```shell
Terraform v1.15.8
on windows_386
```

### VSCode

Instalar idealmente la extensión terraform de hashicorp.

## 2. Terraform overview

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

El plan nos mostrará los recursos a crear (+), actualizar (~) o eliminar (-)

```shell
+ create
~ update in-place
```

Y si estoy de acuerdo con el plan, puedo desplegar los recursos y aplicar el plan

```shell
terraform apply --auto-apply
```

Luego, si desplegué los recursos y quiero eliminar todo lo creado lo puedo hacer con terraform destroy

```shell
terraform destroy --auto-apply
```

## 3. Modifying and deleting resources

A continuación se muestra que ocurre si se modifican o eliminan recursos.

### Modificar recursos

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

### Eliminar recursos

Hay dos formas de eliminar recursos.

La primera consiste en eliminar todos los recursos creados en mi main.tf:

```shell
terraform destroy
```

Y en la segunda puedo eliminar un recurso directamente en mi main.tf (por ejemplo una instancia de EC2) y luego aplicar los cambios

```shell
terraform apply
```

## 4. Referencing resources

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

## 5. Terraform files

A continuación se hará un repaso de los archivos de terraform:

```
.terraform
```

Carpeta que contiene todos los archivos de los providers que utiliza nuestro código. Se crea al ejecutar el comando `terraform init`.

```
terraform.tfstate
```

Archivo con estructura json que contiene todos los recursos que se han creado desde terraform. Cada vez que se crea un recurso nuevo, se elimina o se modifica un recurso se modificará el archivo.

```
main.tf
```

Archivo principal de configuración de Terraform. En él se definen normalmente los providers, recursos y demás bloques que describen la infraestructura que se desea crear.

```
terraform.tfvars
```

Archivo que contiene los valores de las variables de Terraform. Permite separar la configuración específica del entorno del código definido en los archivos `.tf`.

```
.terraform.lock.hcl
```

Archivo de bloqueo de dependencias que registra las versiones y los hashes de los providers utilizados. Terraform lo crea o actualiza al ejecutar `terraform init` para garantizar que se utilicen versiones verificadas y consistentes.



## 6. Terraform commands

Se presentan algunos comandos útiles de terraform.

```shell
terraform
```

Nos muestra la lista de comandos de terraform disponibles.

```shell
terraform state list
```

```shell
aws_subnet.subnet-1
aws_subnet.subnet-2
aws_vpc.production-vpc
```

Nos muestra la lista de recursos en nuestro terraform state. 

```shell
terraform state show aws_vpc.production-vpc
```
```shell
# aws_vpc.production-vpc:
resource "aws_vpc" "production-vpc" {
    arn                                  = "arn:aws:ec2:us-west-2:843335492713:vpc/vpc-04dbce36519e0de9d"
    assign_generated_ipv6_cidr_block     = false
    cidr_block                           = "10.0.0.0/16"
    default_network_acl_id               = "acl-0a5530f4a48484b32"
    default_route_table_id               = "rtb-0c0613b095334db37"
    default_security_group_id            = "sg-06838797be2febc7c"
    dhcp_options_id                      = "dopt-0bee00e7cf9a96b10"
    enable_dns_hostnames                 = false
    enable_dns_support                   = true
    enable_network_address_usage_metrics = false
    id                                   = "vpc-04dbce36519e0de9d"
    instance_tenancy                     = "default"
    ipv6_association_id                  = null
    ipv6_cidr_block                      = null
    ipv6_cidr_block_network_border_group = null
    ipv6_ipam_pool_id                    = null
    ipv6_netmask_length                  = 0
    main_route_table_id                  = "rtb-0c0613b095334db37"
    owner_id                             = "843335492713"
    region                               = "us-west-2"
    tags                                 = {
        "Name" = "main"
    }
    tags_all                             = {
        "Name" = "main"
    }
}
```

El comando `terraform state show <resource>` nos muestra los detalles de un recurso deployeado en terraform, que comúnmente solo se mostraría en la consola de AWS.


```shell
terraform refresh
```
```shell
aws_vpc.production-vpc: Refreshing state... [id=vpc-04dbce36519e0de9d]
aws_subnet.subnet-2: Refreshing state... [id=subnet-035959ddc6c49d695]
aws_subnet.subnet-1: Refreshing state... [id=subnet-0517de9aa90665ac1]

Outputs:

vpc_id = "vpc-04dbce36519e0de9d"
```

El comando terraform refresh actualiza el estado para que sea consistente con AWS. Además nos muestra el output en caso de existir.

## 7. Terraform output

Podemos ver la información de los recursos deployeados por terraform utilizando el comando `terraform state show <resource>`, pero es un poco engorroso. Otra manera de mostrar información de interés de los recursos deployeados por terraform es utilizando el terraform output.

```terraform
resource "aws_vpc" "production-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

output "vpc_id" {
  value = aws_vpc.production-vpc.id
}
```

Ahora, al aplicar `terraform apply` se mostrará en consola el output seleccionado:

```shell
terraform apply
```
```shell
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

vpc_id = "vpc-04dbce36519e0de9d"
```

Esto nos permite mostrar todos los detalles que nos interesen en el output en consola.

## 8. Target resources

Terraform nos permite seleccionar recursos específicos a modificar cuando se aplican cambios o se hace un destroy.

```shell
# destruir un recurso específico
terraform destroy -target aws_subnet.subnet-2 
```

```shell
# aplicar cambios o deployear un recurso específico
terraform apply -target aws_subnet.subnet-2
```

## 9. Terraform variables

Terraform me permite definir variables para ser utilizadas y reutilizadas dentro de mi código. La forma básica de definir variables es la siguiente:

```terraform
variable subnet_prefix {
    description = "cidr block for the subnet"
    // default  = ""
    type        = string
}

resource "aws_subnet" "subnet-1" {
  #referencia al id de la vpc
  vpc_id     = aws_vpc.production-vpc.id 
  cidr_block = var.subnet_prefix

  tags = {
    Name = "subnet-1"
  }
}
```

En mi caso al tener comentado el valor por defecto de la variable terraform me preguntará en la consola cual debiese ser su valor al ejecutar `terraform apply`.

Otra forma de pasar variables puede ser mediante la línea de comandos al ejecutar `terraform apply`:

```shell
terraform apply -var "subnet_prefix=10.0.5.0/24"
```

### terraform.tfvars

Terraform permite crear variables de manera separada mediante el archivo `terraform.tfvars`.

Creamos el archivo y guardamos el valor de la variable:

```terraform
subnet_prefix = "10.0.20.0/24"
```

En este archivo podemos asignar listas, objetos, listas de objetos, etc.

```terraform
list_of_objects = [{cidr_blocks = "10.0.1.0/24", name="prod_subnet"}, {cidr_blocks = "10.0.2.0/24", name="dev_subnet"}]
```