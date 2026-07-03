# Anshin Engine uses pre-cached forecasts and static hazard overlays

Real-time safety monitoring is impossible without connectivity. The Anshin Engine works offline by combining two pre-downloaded layers: a 48-hour weather forecast cached before the user leaves cell coverage, and static hazard overlays (flood zones, exposed ridgelines, dangerous trail segments) sourced from OSM and government datasets. A device barometer, where present, supplements the forecast with local pressure-drop detection. This means the Anshin Engine is only as current as the last cached forecast — users must be informed of this ceiling.

## Consequences

The pre-trip preparation flow must prompt forecast download before the user leaves coverage. The UI must display the forecast cache timestamp so users know how stale their safety data is.
