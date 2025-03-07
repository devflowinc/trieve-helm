# This contains 

## Dependencies

This helm chart contains multiple dependencies for an easy 1 click install process.

It is recommend that these are installed as seperate releases if you plan on doing this in a prodcution environment.

(It is much harder to migrate the databases if they are in a helm release)

- `qdrant`
- `postgres`
- `clickhouse`
- `redis` 
- OIDC provider (`keycloak` is bundled in this chart)

```sh
helm repo add trieve https://devflowinc.github.io/trieve-helm
helm repo update
```
