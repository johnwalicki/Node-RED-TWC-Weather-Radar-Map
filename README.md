# Node-RED-TWC-Weather-Radar-Map

Node-RED Dashboard which displays a time-lapse North America Satellite / Radar Weather map using The Weather Company APIs

Use [The Weather Company APIs](https://www.ibm.com/products/weather-operations-center/data-packages) to display a time-lapse North America Satellite / Radar Weather map on a [Node-RED](https://nodered.org) Dashboard.

This Node-RED flow retrieves map tiles from the [TWC Current Conditions](https://ibm.co/TWCecc) package and, specifically, the [Current Conditions Gridded Tiler APIs](https://ibm.co/v2EHCg). There are many TWC weather map tile layers available.  One of the APIs returns satellite and weather radar tiles.  This simple example grabs zoom level of detail 2, and two map tiles (0,1) and (1,1) of North America. It stitches these 256x256 tiles together using the [node-red-contrib-image-tools](https://flows.nodered.org/node/node-red-contrib-image-tools) nodes. Separately another part of the flow calls a [MapBox API](https://docs.mapbox.com/api/maps/static-tiles/) and retrieves two static baselayer tiles for North America at the same zoom level. Those tiles are [blitted together](https://en.wikipedia.org/wiki/Blit). Finally, the satellite/radar tiles and the baselayer tiles are composited together and displayed in a Node-RED Dashboard.

This example flow and Node-RED Dashboard might be useful as part of a [Call for Code](https://developer.ibm.com/callforcode/) solution. The Call for Code 2021 theme is to help reverse the impact of Climate Change.

Create additional Node-RED flows using the [node-red-contrib-twc-weather](https://flows.nodered.org/node/node-red-contrib-twc-weather) package.

### Prerequistes

- [Install Node-RED](https://nodered.org/docs/getting-started/) on your system or in the cloud
- This flow requires Node-RED v1.3 or higher
- [Add the following nodes](https://nodered.org/docs/user-guide/runtime/adding-nodes) to your Node-RED palette
  - [node-red-dashboard](https://flows.nodered.org/node/node-red-dashboard)
  - [node-red-contrib-image-tools](https://flows.nodered.org/node/node-red-contrib-image-tools)
  - [node-red-node-base64](https://flows.nodered.org/node/node-red-node-base64)
- If you are participating in the [2021 Call for Code](https://developer.ibm.com/callforcode/) you can [register](https://developer.ibm.com/callforcode/tools/weather/) for a time limited TWC API key.
- Learn more about the TWC APIs used in this Node-RED flow by reading the [TWC Current Conditions API documentation](https://ibm.co/TWCecc)
- Request a free [Mapbox Developer](https://docs.mapbox.com/) token.

## API Keys

Set your TWC API and MapBox API keys as environment variables before starting Node-RED

```sh
export TWCAPIKEY=<TWC API KEY>
export MAPBOXTOKEN=<MapBox Token>
```

## Node-RED flow in this repository:
---
### A flow that displays Weather Radar images on a map

![Weather Radar Dashboard](screenshots/TWC-WeatherRadarMap-animation.gif?raw=true "Weather Radar Map Dashboard")
<p align="center">
  <strong>Get the Code: <a href="radarmap-flows.json">Node-RED flow for Weather Radar Dashboard</strong></a>
</p>

![Weather Radar Map flow](screenshots/TWC-WeatherRadarMap-flow.png?raw=true "Weather Radar Map flow")
---

### Authors

- [John Walicki](https://github.com/johnwalicki)

___

Enjoy!  Give us [feedback](https://github.com/johnwalicki/Node-RED-TWC-Weather-Radar-Map/issues) if you have suggestions on how to improve this tutorial.

## License

This tutorial is licensed under the Apache Software License, Version 2.  Separate third party code objects invoked within this code pattern are licensed by their respective providers pursuant to their own separate licenses. Contributions are subject to the [Developer Certificate of Origin, Version 1.1 (DCO)](https://developercertificate.org/) and the [Apache Software License, Version 2](http://www.apache.org/licenses/LICENSE-2.0.txt).
