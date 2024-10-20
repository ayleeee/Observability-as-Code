resource "grafana_contact_point" "slack_contact_point" {
  name = "Slack-Alert"

  slack {
    url = "https://hooks.slack.com/services/"
    icon_url = "https://grafana.com/static/img/fav32.png"
    title    = "High CPU Alert"
    text     = "Alert: High CPU usage detected. Please check the system immediately."
  }
}

resource "grafana_notification_policy" "cpu_notification_policy" {
  group_by      = ["alertname"]
  contact_point = grafana_contact_point.slack_contact_point.name

  policy {
    matcher {
      label = "alertname"
      match = "="
      value = "High CPU Usage Alert"
    }
    contact_point = grafana_contact_point.slack_contact_point.name
  }
}

resource "grafana_folder" "prometheus_alert"{
  title = "Prometheus Alert Provisioning by Terraform"
}

resource "grafana_rule_group" "my_rule_group" {
  name            = "CPU Alert Rules"
  folder_uid      = grafana_folder.prometheus_alert.uid
  interval_seconds = 60
  
  rule {
    name     = "High CPU Usage Alert"
    condition = "C"
    for      = "2m"

    data {
      ref_id = "A"
      relative_time_range {
        from = 600
        to   = 0
      }
      datasource_uid = grafana_data_source.prometheus.uid
      model = jsonencode({
        intervalMs    = 1000
        maxDataPoints = 43200
        refId         = "A"
        expr          = "100 - (avg(irate(node_cpu_seconds_total{mode='idle'}[1m])) * 100)"
      })
    }

    data {
      datasource_uid = "-100"
      model = <<EOT
{
  "conditions": [
    {
      "evaluator": { "params": [80], "type": "gt" },
      "operator": { "type": "and" },
      "query": { "params": ["A"] },
      "reducer": { "type": "last" },
      "type": "query"
    }
  ],
  "datasource": { "name": "Expression", "type": "__expr__", "uid": "__expr__" },
  "expression": "A",
  "hide": false,
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "refId": "B",
  "type": "reduce"
}
EOT
      ref_id = "B"
      relative_time_range {
        from = 0
        to   = 0
      }
    }

    data {
      datasource_uid = "-100"
      ref_id = "C"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        expression = "$B > 80"
        type       = "math"
        refId      = "C"
      })
    }

    labels = {
      severity = "critical"
    }

    annotations = {
      summary = "CPU usage is above 80%"
    }
  }
}

resource "grafana_data_source" "prometheus" {
  type = "prometheus"
  name = "prometheus"
  url  = ""
}

resource "grafana_data_source" "loki" {
  type = "loki"
  name = "loki"
  url = ""
}

resource "grafana_data_source" "tempo" {
  type = "tempo"
  name = "tempo"
  url = ""
}
