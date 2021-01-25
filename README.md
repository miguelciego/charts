# helm-chart for Sorbotics aplications

## Create new chart

Para crear un nuevo chart en el directorio helm-chart-sources/

```bash
helm create helm-chart-sources/nombre_repo
```
## Package all chart 

Comando para empaquetar todos los chart en el directorio helm-chart-sources

```bash
helm package helm-chart-sources/*
```

## Update index.yaml file

Comando para actualizar el archivo index.yaml

```bash
helm repo index . --url https://miguelciego.github.io/charts/
```