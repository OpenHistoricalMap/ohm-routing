# ohm-routing

Routing over OpenHistoricalMap data, filtered by date. Uses GraphHopper with a small plugin that stores `start_date`/`end_date` of each way, so a route only uses ways that existed on the selected date. Issues #506 and #695.

Test page: https://routing.ohmstaging.org

## Layout

- `src/` GraphHopper plugin. Stores `start_date`/`end_date` as `ohm_start`/`ohm_end` (decimal years, same conversion as the tiler).
- `config/` GraphHopper config and the `car`, `foot`, `horse` and `carriage` profiles.
- `scripts/`
  - `start.sh` starts the server from the current graph. Builds one first if there is none for this image version.
  - `update.sh` applies replication diffs to the planet, builds a new graph and restarts the server.
- `Dockerfile` builds GraphHopper with the plugin plus the scripts. Published to `ghcr.io/openhistoricalmap/ohm-routing`.
- `chart/ohm-routing` Helm chart: server, update CronJob (every 2 hours), test page and Ingress.

## How updates work

The volume keeps the planet and the graphs:

```
/data/planet.osm.pbf
/data/graphs/<version>-<timestamp>/
/data/graphs/current -> <version>-<timestamp>
```

`update.sh` runs `pyosmium-up-to-date` on the planet. If there is new data, it builds a new graph next to the current one, switches `current` and does a rolling restart. The new pod loads the graph before the old one stops, so there is no downtime. A full planet is downloaded again every 7 days.

`<version>` is a hash of `config/` and `src/`. A graph only loads with the same profiles and encoded values, so after a config change the server builds a new graph on start.

## Deploy

```bash
helm upgrade --install routing chart/ohm-routing -n routing --create-namespace \
  --set image.tag=<tag> \
  --set ingress.enabled=true --set ingress.host=routing.ohmstaging.org
```

## Request

```bash
curl https://routing.ohmstaging.org/route -H 'Content-Type: application/json' -d '{
  "points": [[2.3222, 48.8366], [2.3822, 48.8766]],
  "profile": "car",
  "custom_model": {"priority": [{"if": "ohm_start > 1900.5 || ohm_end < 1900.5", "multiply_by": "0"}]}
}'
```
