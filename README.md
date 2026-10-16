# graphhopper-ohm

Routing over OHM data, filtered by date. PoC for issues #506 and #695.

- `src/` GraphHopper plugin. Stores `start_date`/`end_date` of each way as `ohm_start`/`ohm_end` (decimal years, same conversion as the tiler).
- `config/` GraphHopper config and `car`/`foot` profiles.
- `web/` test page: pick A and B, choose a date, see the route and the ways it uses.
- `k8s.yaml` builds GraphHopper 11.1 with the plugin, downloads the planet, imports and serves it.

Test page: https://routing.ohmstaging.org

## Deploy (staging)

```bash
kubectl create namespace routing-poc
kubectl -n routing-poc create configmap graphhopper-ohm-src --from-file=src/org/openhistoricalmap/routing/
kubectl -n routing-poc create configmap graphhopper-ohm-config --from-file=config/
kubectl -n routing-poc create configmap routing-web --from-file=web/
kubectl apply -f k8s.yaml
```

To rebuild the graph after a config change, delete `/data/graph-cache` in the pod and restart the deployment.

## Request

```bash
curl https://routing.ohmstaging.org/route -H 'Content-Type: application/json' -d '{
  "points": [[2.3222, 48.8366], [2.3822, 48.8766]],
  "profile": "car",
  "custom_model": {"priority": [{"if": "ohm_start > 1900.5 || ohm_end < 1900.5", "multiply_by": "0"}]}
}'
```
