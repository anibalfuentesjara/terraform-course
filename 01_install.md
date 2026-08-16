# Instalación de terraform

## Windows

1. Descargar el ejecutable desde la página https://developer.hashicorp.com/terraform/install
2. Poner el ejecutable en alguna carpeta, ejemplo: `C:\Program Files (x86)\Terraform`
3. Agregar la ruta a las variables de entorno (env), para ello buscar las variables de entorno en la barra, luego en variables de sistema buscar `Path`, agregar posteriormente la ruta del ejecutable.
4. Abrir una terminal (por ejemplo powershell)
 y ejecutar `terraform -v` . Debiese mostrar la versión, ej: 

```shell
Terraform v1.15.8
on windows_386
```

## VSCode

Instalar idealmente la extensión terraform de hashicorp.
