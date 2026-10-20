# ohm-routing

GraphHopper plugin to route over OpenHistoricalMap data by date. It stores `start_date`/`end_date` of each way as `ohm_start`/`ohm_end` (decimal years, same conversion as the tiler), so a request can block the ways that did not exist on a given date. Issues #506 and #695.

Test page: https://routing.ohmstaging.org

- `src/` the plugin: `OhmDate` (date conversion), `OhmDateParser` (encoded values), `OhmImportRegistry` (registers them in GraphHopper).
- `test/` checks `OhmDate` against the tiler conversion.

The Docker image, profiles, update scripts and Kubernetes manifests live in [ohm-deploy](https://github.com/OpenHistoricalMap/ohm-deploy): `images/routing` and `ohm/templates/routing`. The image builds the plugin from this repo at a pinned commit.

## Build and test

```bash
v=11.1
curl -fsSLO https://repo1.maven.org/maven2/com/graphhopper/graphhopper-core/$v/graphhopper-core-$v.jar
curl -fsSLO https://repo1.maven.org/maven2/com/graphhopper/graphhopper-web-api/$v/graphhopper-web-api-$v.jar
javac -d out -cp graphhopper-core-$v.jar:graphhopper-web-api-$v.jar src/org/openhistoricalmap/routing/*.java
javac -d out -cp out test/OhmDateTest.java && java -cp out OhmDateTest
```

## Request

```bash
curl https://routing.ohmstaging.org/route -H 'Content-Type: application/json' -d '{
  "points": [[2.3222, 48.8366], [2.3822, 48.8766]],
  "profile": "car",
  "custom_model": {"priority": [{"if": "ohm_start > 1900.5 || ohm_end < 1900.5", "multiply_by": "0"}]}
}'
```
