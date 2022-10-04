resource "mimir_rule_group_alerting" "example" {
  name      = "example"
  namespace = "my_namespace"

  rule {
    alert = "HighRequestLatency"
    expr  = "sum by (job) (http_inprogress_requests)"
    for   = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      test = "annotation value"
    }
  }
}

resource "mimir_rule_group_recording" "mimir_ingester_rules" {
  name      = "mimir_ingester_rules"
  namespace = "my_namespace"

  rule {
    record = "cluster_namespace_pod:cortex_ingester_ingested_samples_total:rate1m"
    expr   = "sum by(cluster, namespace, pod) (rate(cortex_ingester_ingested_samples_total[1m]))"
  }
}

