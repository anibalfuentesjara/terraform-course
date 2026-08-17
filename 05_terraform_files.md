# Terraform files

A continuación se hará un repaso de los archivos de terraform:

```
.terraform
```

Carpeta que contiene todos los archivos de los providers que utiliza nuestro código. Se crea al ejecutar el comando `terraform init`.

```
terraform.tfstate
```

Archivo con estructura json que contiene todos los recursos que se han creado desde terraform. Cada vez que se crea un recurso nuevo, se elimina o se modifica un recurso se modificará el archivo.