> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Prometheus and Grafana Metrics for Blockscout

> Export Blockscout metrics on /metrics for Prometheus and visualize node and web performance in Grafana dashboards using BEAM dashboards.

## Prometheus

BlockScout is set up to export [Prometheus](https://prometheus.io/) metrics at `/metrics`.

1. Install prometheus: `brew install prometheus`
2. Start the web server `iex -S mix phx.server`
3. Start prometheus: `prometheus --config.file=prometheus.yml`

## Grafana

The Grafana dashboard may also be used for metrics display.

1. Install grafana: `brew install grafana`

2. Install Pie Chart panel plugin: `grafana-cli plugins install grafana-piechart-panel`

3. Start grafana: `brew services start grafana`

4. Add Prometheus as a Data Source

   a. `open http://localhost:3000/datasources`

   b. Click "+ Add data source"

   c. Put "Prometheus" for "Name"

   d. Change "Type" to "Prometheus"

   e. Set "URL" to "[http://localhost:9090](http://localhost:9090)"

   f. Set "Scrape Interval" to "10s"

5. Add the dashboards from [https://github.com/deadtrickster/beam-dashboards](https://github.com/deadtrickster/beam-dashboards): For each `*.json` file in the repo.

   a. `open http://localhost:3000/dashboard/import`

   b. Copy the contents of the JSON file in the "Or paste JSON" entry

   c. Click "Load"

6. View the dashboards. (You will need to click-around and use BlockScout for the web-related metrics to show up.)

Examples of dashboards:

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/JTppjXqh5Q4u166M/images/1954a0f5-image.jpeg?fit=max&auto=format&n=JTppjXqh5Q4u166M&q=85&s=2690af0dbd696cafc94365c1ad753155" width="1376" height="1169" data-path="images/1954a0f5-image.jpeg" />
</Frame>

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/a5ae511c-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=19eb9aba27f4f3d9df5d7ba8efa6d41c" width="1376" height="1169" data-path="images/a5ae511c-image.jpeg" />
</Frame>

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/d8d70978-image.jpeg?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=46ea27cb2eca2d8eac2a0cbc6030608f" width="1376" height="1169" data-path="images/d8d70978-image.jpeg" />
</Frame>
