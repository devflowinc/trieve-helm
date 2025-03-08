# This contains 

## Dependencies

This helm chart contains multiple dependencies for an easy 1 click install process.

It is recommend that these are installed as seperate releases if you plan on doing this in a prodcution environment.

(It is much harder to migrate the databases if they are in a helm release)

- `qdrant` via officially supported subchart
- `postgres` (custom subchart using cnpg operator)
- `clickhouse` (custom subchart using clickhouse-operator)
- `redis` via bitnami redis subchart
- OIDC provider (`keycloak` is bundled in this chart)

```sh
helm repo add trieve https://devflowinc.github.io/trieve-helm
helm repo update
helm upgrade trieve-local -i trieve/trieve
```
