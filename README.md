# mimir2tf - Mimir YAML Prometheus Rules to Terraform HCL converter

A tool for converting Mimir Prometheus Rules (in YAML format) into HashiCorp's Terraform configuration language.

The converted `.tf` files are suitable for use with the [Terraform Mimir Provider](https://registry.terraform.io/providers/fgouteroux/mimir/latest/docs)


## Installation

**Pre-built Binaries**

Download Binary from GitHub [releases](https://github.com/fgouteroux/mimir2tf/releases/latest) page.


## YAML to HCL

**Convert a single YAML file and write generated Terraform config to Stdout**

```
$ mimir2tf -f test-fixtures/rules.yaml

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
```

**Convert a single YAML file and write output to file**

```
$ mimir2tf -f test-fixtures/rules.yaml -o rules.tf
```

**Convert a directory of Mimir YAML files and write output to stdout**

```
$ mimir2tf -f test-fixtures/
```

**Convert a directory of Mimir YAML files and write output to file**

```
$ mimir2tf -f test-fixtures/ -o /tmp/mimir-alerts-rules.tf
```

## HCL to YAML

**Convert a single HCL file and write yaml output to file**

```
$ mimir2tf -r -f test-fixtures/mimir-rules.tf -o /tmp/mimir-rules.yaml
```

**Convert a directory of Mimir HCL files to YAML file**

```
$ mimir2tf -r -f test-fixtures -o /tmp/mimir-alert-rules.yaml

```

Then validate with [promtool](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/#syntax-checking-rules)
```
$ promtool check rules /tmp/mimir-alert-rules.yaml
Checking /tmp/mimir-alert-rules.yaml
2 duplicate rule(s) found.
Metric: MimirCompactorHasNotUploadedBlocks
Label(s):
  severity: critical
Metric: MimirRolloutStuck
Label(s):
  severity: warning
Might cause inconsistency while recording expressions.
  SUCCESS: 194 rules found
```

## Building

> **NOTE** Requires a working Golang build environment.

This project uses Golang modules for dependency management, so it can be cloned outside of the `$GOPATH`.

**Clone the repository**

```
$ git clone https://github.com/fgouteroux/mimir2tf.git
```

**Build**

```
$ cd mimir2tf
$ make build
```
