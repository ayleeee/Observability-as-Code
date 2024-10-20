resource "grafana_dashboard" "cpu_dashboard" {
  config_json = jsonencode({
    title = "Full Observability Dashboard",
    panels = [
      {
        type  = "timeseries",
        title = "CPU Usage Over Time",
        datasource = grafana_data_source.prometheus.uid,
        targets = [
          {
            expr = "100 - (avg(irate(node_cpu_seconds_total{mode='idle'}[5m])) * 100)",
            refId = "A",
            legendFormat = "CPU Usage (%)"
          }
        ],
        fieldConfig = {
          defaults = {
            unit = "percent",
            thresholds = {
              mode = "absolute",
              steps = [
                {
                  color = "green",
                  value = 0
                },
                {
                  color = "yellow",
                  value = 80
                },
                {
                  color = "red",
                  value = 90
                }
              ]
            }
          }
        },
        options = {
          tooltip = {
            mode = "single"
          }
        },
        gridPos = {
          h = 8,
          w = 24,
          x = 0,
          y = 0
        }
      },
      {
        type  = "logs",
        title = "System Logs",
        datasource = grafana_data_source.loki.uid,
        targets = [
          {
            expr = "{job=\"varlogs\"}",
            refId = "B"
          }
        ],
        gridPos = {
          h = 8,
          w = 24,
          x = 0,
          y = 8
        }
      },
      {
        type  = "table",
        title = "Event Logs",
        datasource = grafana_data_source.prometheus.uid,
        targets = [
          {
            expr = "up",
            refId = "C"
          }
        ],
        gridPos = {
          h = 8,
          w = 24,
          x = 0,
          y = 16
        }
      },
{
  type  = "table",
  title = "Trace Monitoring",
  datasource = grafana_data_source.tempo.uid,
  targets = [
          {
            query = "{resource.service.name=\"flask\" && name=\"some_operation\"} ",
            refId = "B"
          }
        ],
  gridPos = {
    h = 8,
    w = 24,
    x = 0,
    y = 24
  },
  options = {
    showTable = true,    # Enable table view by default
  }
}
    ],
    time = {
      from = "now-1h",
      to   = "now"
    },
    timepicker = {
      refresh_intervals = ["5s", "10s", "30s", "1m", "5m", "15m", "1h", "6h", "12h", "24h"]
    }
  })
}
