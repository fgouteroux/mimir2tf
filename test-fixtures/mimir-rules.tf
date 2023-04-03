resource "mimir_rule_group_recording" "mimir_api_1" {
  name = "mimir_api_1"

  rule {
    record = "cluster_job:cortex_request_duration_seconds:99quantile"
    expr   = "histogram_quantile(0.99, sum(rate(cortex_request_duration_seconds_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_request_duration_seconds:50quantile"
    expr   = "histogram_quantile(0.50, sum(rate(cortex_request_duration_seconds_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_request_duration_seconds:avg"
    expr   = "sum(rate(cortex_request_duration_seconds_sum[1m])) by (cluster, job) / sum(rate(cortex_request_duration_seconds_count[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_request_duration_seconds_bucket:sum_rate"
    expr   = "sum(rate(cortex_request_duration_seconds_bucket[1m])) by (le, cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_request_duration_seconds_sum:sum_rate"
    expr   = "sum(rate(cortex_request_duration_seconds_sum[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_request_duration_seconds_count:sum_rate"
    expr   = "sum(rate(cortex_request_duration_seconds_count[1m])) by (cluster, job)"
  }
}

resource "mimir_rule_group_recording" "mimir_api_2" {
  name = "mimir_api_2"

  rule {
    record = "cluster_job_route:cortex_request_duration_seconds:99quantile"
    expr   = "histogram_quantile(0.99, sum(rate(cortex_request_duration_seconds_bucket[1m])) by (le, cluster, job, route))"
  }

  rule {
    record = "cluster_job_route:cortex_request_duration_seconds:50quantile"
    expr   = "histogram_quantile(0.50, sum(rate(cortex_request_duration_seconds_bucket[1m])) by (le, cluster, job, route))"
  }

  rule {
    record = "cluster_job_route:cortex_request_duration_seconds:avg"
    expr   = "sum(rate(cortex_request_duration_seconds_sum[1m])) by (cluster, job, route) / sum(rate(cortex_request_duration_seconds_count[1m])) by (cluster, job, route)"
  }

  rule {
    record = "cluster_job_route:cortex_request_duration_seconds_bucket:sum_rate"
    expr   = "sum(rate(cortex_request_duration_seconds_bucket[1m])) by (le, cluster, job, route)"
  }

  rule {
    record = "cluster_job_route:cortex_request_duration_seconds_sum:sum_rate"
    expr   = "sum(rate(cortex_request_duration_seconds_sum[1m])) by (cluster, job, route)"
  }

  rule {
    record = "cluster_job_route:cortex_request_duration_seconds_count:sum_rate"
    expr   = "sum(rate(cortex_request_duration_seconds_count[1m])) by (cluster, job, route)"
  }
}

resource "mimir_rule_group_recording" "mimir_api_3" {
  name = "mimir_api_3"

  rule {
    record = "cluster_namespace_job_route:cortex_request_duration_seconds:99quantile"
    expr   = "histogram_quantile(0.99, sum(rate(cortex_request_duration_seconds_bucket[1m])) by (le, cluster, namespace, job, route))"
  }

  rule {
    record = "cluster_namespace_job_route:cortex_request_duration_seconds:50quantile"
    expr   = "histogram_quantile(0.50, sum(rate(cortex_request_duration_seconds_bucket[1m])) by (le, cluster, namespace, job, route))"
  }

  rule {
    record = "cluster_namespace_job_route:cortex_request_duration_seconds:avg"
    expr   = "sum(rate(cortex_request_duration_seconds_sum[1m])) by (cluster, namespace, job, route) / sum(rate(cortex_request_duration_seconds_count[1m])) by (cluster, namespace, job, route)"
  }

  rule {
    record = "cluster_namespace_job_route:cortex_request_duration_seconds_bucket:sum_rate"
    expr   = "sum(rate(cortex_request_duration_seconds_bucket[1m])) by (le, cluster, namespace, job, route)"
  }

  rule {
    record = "cluster_namespace_job_route:cortex_request_duration_seconds_sum:sum_rate"
    expr   = "sum(rate(cortex_request_duration_seconds_sum[1m])) by (cluster, namespace, job, route)"
  }

  rule {
    record = "cluster_namespace_job_route:cortex_request_duration_seconds_count:sum_rate"
    expr   = "sum(rate(cortex_request_duration_seconds_count[1m])) by (cluster, namespace, job, route)"
  }
}

resource "mimir_rule_group_recording" "mimir_querier_api" {
  name = "mimir_querier_api"

  rule {
    record = "cluster_job:cortex_querier_request_duration_seconds:99quantile"
    expr   = "histogram_quantile(0.99, sum(rate(cortex_querier_request_duration_seconds_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_querier_request_duration_seconds:50quantile"
    expr   = "histogram_quantile(0.50, sum(rate(cortex_querier_request_duration_seconds_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_querier_request_duration_seconds:avg"
    expr   = "sum(rate(cortex_querier_request_duration_seconds_sum[1m])) by (cluster, job) / sum(rate(cortex_querier_request_duration_seconds_count[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_querier_request_duration_seconds_bucket:sum_rate"
    expr   = "sum(rate(cortex_querier_request_duration_seconds_bucket[1m])) by (le, cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_querier_request_duration_seconds_sum:sum_rate"
    expr   = "sum(rate(cortex_querier_request_duration_seconds_sum[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_querier_request_duration_seconds_count:sum_rate"
    expr   = "sum(rate(cortex_querier_request_duration_seconds_count[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job_route:cortex_querier_request_duration_seconds:99quantile"
    expr   = "histogram_quantile(0.99, sum(rate(cortex_querier_request_duration_seconds_bucket[1m])) by (le, cluster, job, route))"
  }

  rule {
    record = "cluster_job_route:cortex_querier_request_duration_seconds:50quantile"
    expr   = "histogram_quantile(0.50, sum(rate(cortex_querier_request_duration_seconds_bucket[1m])) by (le, cluster, job, route))"
  }

  rule {
    record = "cluster_job_route:cortex_querier_request_duration_seconds:avg"
    expr   = "sum(rate(cortex_querier_request_duration_seconds_sum[1m])) by (cluster, job, route) / sum(rate(cortex_querier_request_duration_seconds_count[1m])) by (cluster, job, route)"
  }

  rule {
    record = "cluster_job_route:cortex_querier_request_duration_seconds_bucket:sum_rate"
    expr   = "sum(rate(cortex_querier_request_duration_seconds_bucket[1m])) by (le, cluster, job, route)"
  }

  rule {
    record = "cluster_job_route:cortex_querier_request_duration_seconds_sum:sum_rate"
    expr   = "sum(rate(cortex_querier_request_duration_seconds_sum[1m])) by (cluster, job, route)"
  }

  rule {
    record = "cluster_job_route:cortex_querier_request_duration_seconds_count:sum_rate"
    expr   = "sum(rate(cortex_querier_request_duration_seconds_count[1m])) by (cluster, job, route)"
  }

  rule {
    record = "cluster_namespace_job_route:cortex_querier_request_duration_seconds:99quantile"
    expr   = "histogram_quantile(0.99, sum(rate(cortex_querier_request_duration_seconds_bucket[1m])) by (le, cluster, namespace, job, route))"
  }

  rule {
    record = "cluster_namespace_job_route:cortex_querier_request_duration_seconds:50quantile"
    expr   = "histogram_quantile(0.50, sum(rate(cortex_querier_request_duration_seconds_bucket[1m])) by (le, cluster, namespace, job, route))"
  }

  rule {
    record = "cluster_namespace_job_route:cortex_querier_request_duration_seconds:avg"
    expr   = "sum(rate(cortex_querier_request_duration_seconds_sum[1m])) by (cluster, namespace, job, route) / sum(rate(cortex_querier_request_duration_seconds_count[1m])) by (cluster, namespace, job, route)"
  }

  rule {
    record = "cluster_namespace_job_route:cortex_querier_request_duration_seconds_bucket:sum_rate"
    expr   = "sum(rate(cortex_querier_request_duration_seconds_bucket[1m])) by (le, cluster, namespace, job, route)"
  }

  rule {
    record = "cluster_namespace_job_route:cortex_querier_request_duration_seconds_sum:sum_rate"
    expr   = "sum(rate(cortex_querier_request_duration_seconds_sum[1m])) by (cluster, namespace, job, route)"
  }

  rule {
    record = "cluster_namespace_job_route:cortex_querier_request_duration_seconds_count:sum_rate"
    expr   = "sum(rate(cortex_querier_request_duration_seconds_count[1m])) by (cluster, namespace, job, route)"
  }
}

resource "mimir_rule_group_recording" "mimir_cache" {
  name = "mimir_cache"

  rule {
    record = "cluster_job_method:cortex_memcache_request_duration_seconds:99quantile"
    expr   = "histogram_quantile(0.99, sum(rate(cortex_memcache_request_duration_seconds_bucket[1m])) by (le, cluster, job, method))"
  }

  rule {
    record = "cluster_job_method:cortex_memcache_request_duration_seconds:50quantile"
    expr   = "histogram_quantile(0.50, sum(rate(cortex_memcache_request_duration_seconds_bucket[1m])) by (le, cluster, job, method))"
  }

  rule {
    record = "cluster_job_method:cortex_memcache_request_duration_seconds:avg"
    expr   = "sum(rate(cortex_memcache_request_duration_seconds_sum[1m])) by (cluster, job, method) / sum(rate(cortex_memcache_request_duration_seconds_count[1m])) by (cluster, job, method)"
  }

  rule {
    record = "cluster_job_method:cortex_memcache_request_duration_seconds_bucket:sum_rate"
    expr   = "sum(rate(cortex_memcache_request_duration_seconds_bucket[1m])) by (le, cluster, job, method)"
  }

  rule {
    record = "cluster_job_method:cortex_memcache_request_duration_seconds_sum:sum_rate"
    expr   = "sum(rate(cortex_memcache_request_duration_seconds_sum[1m])) by (cluster, job, method)"
  }

  rule {
    record = "cluster_job_method:cortex_memcache_request_duration_seconds_count:sum_rate"
    expr   = "sum(rate(cortex_memcache_request_duration_seconds_count[1m])) by (cluster, job, method)"
  }

  rule {
    record = "cluster_job:cortex_cache_request_duration_seconds:99quantile"
    expr   = "histogram_quantile(0.99, sum(rate(cortex_cache_request_duration_seconds_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_cache_request_duration_seconds:50quantile"
    expr   = "histogram_quantile(0.50, sum(rate(cortex_cache_request_duration_seconds_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_cache_request_duration_seconds:avg"
    expr   = "sum(rate(cortex_cache_request_duration_seconds_sum[1m])) by (cluster, job) / sum(rate(cortex_cache_request_duration_seconds_count[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_cache_request_duration_seconds_bucket:sum_rate"
    expr   = "sum(rate(cortex_cache_request_duration_seconds_bucket[1m])) by (le, cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_cache_request_duration_seconds_sum:sum_rate"
    expr   = "sum(rate(cortex_cache_request_duration_seconds_sum[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_cache_request_duration_seconds_count:sum_rate"
    expr   = "sum(rate(cortex_cache_request_duration_seconds_count[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job_method:cortex_cache_request_duration_seconds:99quantile"
    expr   = "histogram_quantile(0.99, sum(rate(cortex_cache_request_duration_seconds_bucket[1m])) by (le, cluster, job, method))"
  }

  rule {
    record = "cluster_job_method:cortex_cache_request_duration_seconds:50quantile"
    expr   = "histogram_quantile(0.50, sum(rate(cortex_cache_request_duration_seconds_bucket[1m])) by (le, cluster, job, method))"
  }

  rule {
    record = "cluster_job_method:cortex_cache_request_duration_seconds:avg"
    expr   = "sum(rate(cortex_cache_request_duration_seconds_sum[1m])) by (cluster, job, method) / sum(rate(cortex_cache_request_duration_seconds_count[1m])) by (cluster, job, method)"
  }

  rule {
    record = "cluster_job_method:cortex_cache_request_duration_seconds_bucket:sum_rate"
    expr   = "sum(rate(cortex_cache_request_duration_seconds_bucket[1m])) by (le, cluster, job, method)"
  }

  rule {
    record = "cluster_job_method:cortex_cache_request_duration_seconds_sum:sum_rate"
    expr   = "sum(rate(cortex_cache_request_duration_seconds_sum[1m])) by (cluster, job, method)"
  }

  rule {
    record = "cluster_job_method:cortex_cache_request_duration_seconds_count:sum_rate"
    expr   = "sum(rate(cortex_cache_request_duration_seconds_count[1m])) by (cluster, job, method)"
  }
}

resource "mimir_rule_group_recording" "mimir_storage" {
  name = "mimir_storage"

  rule {
    record = "cluster_job:cortex_kv_request_duration_seconds:99quantile"
    expr   = "histogram_quantile(0.99, sum(rate(cortex_kv_request_duration_seconds_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_kv_request_duration_seconds:50quantile"
    expr   = "histogram_quantile(0.50, sum(rate(cortex_kv_request_duration_seconds_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_kv_request_duration_seconds:avg"
    expr   = "sum(rate(cortex_kv_request_duration_seconds_sum[1m])) by (cluster, job) / sum(rate(cortex_kv_request_duration_seconds_count[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_kv_request_duration_seconds_bucket:sum_rate"
    expr   = "sum(rate(cortex_kv_request_duration_seconds_bucket[1m])) by (le, cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_kv_request_duration_seconds_sum:sum_rate"
    expr   = "sum(rate(cortex_kv_request_duration_seconds_sum[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_kv_request_duration_seconds_count:sum_rate"
    expr   = "sum(rate(cortex_kv_request_duration_seconds_count[1m])) by (cluster, job)"
  }
}

resource "mimir_rule_group_recording" "mimir_queries" {
  name = "mimir_queries"

  rule {
    record = "cluster_job:cortex_query_frontend_retries:99quantile"
    expr   = "histogram_quantile(0.99, sum(rate(cortex_query_frontend_retries_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_query_frontend_retries:50quantile"
    expr   = "histogram_quantile(0.50, sum(rate(cortex_query_frontend_retries_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_query_frontend_retries:avg"
    expr   = "sum(rate(cortex_query_frontend_retries_sum[1m])) by (cluster, job) / sum(rate(cortex_query_frontend_retries_count[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_query_frontend_retries_bucket:sum_rate"
    expr   = "sum(rate(cortex_query_frontend_retries_bucket[1m])) by (le, cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_query_frontend_retries_sum:sum_rate"
    expr   = "sum(rate(cortex_query_frontend_retries_sum[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_query_frontend_retries_count:sum_rate"
    expr   = "sum(rate(cortex_query_frontend_retries_count[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_query_frontend_queue_duration_seconds:99quantile"
    expr   = "histogram_quantile(0.99, sum(rate(cortex_query_frontend_queue_duration_seconds_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_query_frontend_queue_duration_seconds:50quantile"
    expr   = "histogram_quantile(0.50, sum(rate(cortex_query_frontend_queue_duration_seconds_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_query_frontend_queue_duration_seconds:avg"
    expr   = "sum(rate(cortex_query_frontend_queue_duration_seconds_sum[1m])) by (cluster, job) / sum(rate(cortex_query_frontend_queue_duration_seconds_count[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_query_frontend_queue_duration_seconds_bucket:sum_rate"
    expr   = "sum(rate(cortex_query_frontend_queue_duration_seconds_bucket[1m])) by (le, cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_query_frontend_queue_duration_seconds_sum:sum_rate"
    expr   = "sum(rate(cortex_query_frontend_queue_duration_seconds_sum[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_query_frontend_queue_duration_seconds_count:sum_rate"
    expr   = "sum(rate(cortex_query_frontend_queue_duration_seconds_count[1m])) by (cluster, job)"
  }
}

resource "mimir_rule_group_recording" "mimir_ingester_queries" {
  name = "mimir_ingester_queries"

  rule {
    record = "cluster_job:cortex_ingester_queried_series:99quantile"
    expr   = "histogram_quantile(0.99, sum(rate(cortex_ingester_queried_series_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_series:50quantile"
    expr   = "histogram_quantile(0.50, sum(rate(cortex_ingester_queried_series_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_series:avg"
    expr   = "sum(rate(cortex_ingester_queried_series_sum[1m])) by (cluster, job) / sum(rate(cortex_ingester_queried_series_count[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_series_bucket:sum_rate"
    expr   = "sum(rate(cortex_ingester_queried_series_bucket[1m])) by (le, cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_series_sum:sum_rate"
    expr   = "sum(rate(cortex_ingester_queried_series_sum[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_series_count:sum_rate"
    expr   = "sum(rate(cortex_ingester_queried_series_count[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_samples:99quantile"
    expr   = "histogram_quantile(0.99, sum(rate(cortex_ingester_queried_samples_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_samples:50quantile"
    expr   = "histogram_quantile(0.50, sum(rate(cortex_ingester_queried_samples_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_samples:avg"
    expr   = "sum(rate(cortex_ingester_queried_samples_sum[1m])) by (cluster, job) / sum(rate(cortex_ingester_queried_samples_count[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_samples_bucket:sum_rate"
    expr   = "sum(rate(cortex_ingester_queried_samples_bucket[1m])) by (le, cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_samples_sum:sum_rate"
    expr   = "sum(rate(cortex_ingester_queried_samples_sum[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_samples_count:sum_rate"
    expr   = "sum(rate(cortex_ingester_queried_samples_count[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_exemplars:99quantile"
    expr   = "histogram_quantile(0.99, sum(rate(cortex_ingester_queried_exemplars_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_exemplars:50quantile"
    expr   = "histogram_quantile(0.50, sum(rate(cortex_ingester_queried_exemplars_bucket[1m])) by (le, cluster, job))"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_exemplars:avg"
    expr   = "sum(rate(cortex_ingester_queried_exemplars_sum[1m])) by (cluster, job) / sum(rate(cortex_ingester_queried_exemplars_count[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_exemplars_bucket:sum_rate"
    expr   = "sum(rate(cortex_ingester_queried_exemplars_bucket[1m])) by (le, cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_exemplars_sum:sum_rate"
    expr   = "sum(rate(cortex_ingester_queried_exemplars_sum[1m])) by (cluster, job)"
  }

  rule {
    record = "cluster_job:cortex_ingester_queried_exemplars_count:sum_rate"
    expr   = "sum(rate(cortex_ingester_queried_exemplars_count[1m])) by (cluster, job)"
  }
}

resource "mimir_rule_group_recording" "mimir_received_samples" {
  name = "mimir_received_samples"

  rule {
    record = "cluster_namespace_job:cortex_distributor_received_samples:rate5m"
    expr   = "sum by (cluster, namespace, job) (rate(cortex_distributor_received_samples_total[5m]))"
  }
}

resource "mimir_rule_group_recording" "mimir_exemplars_in" {
  name = "mimir_exemplars_in"

  rule {
    record = "cluster_namespace_job:cortex_distributor_exemplars_in:rate5m"
    expr   = "sum by (cluster, namespace, job) (rate(cortex_distributor_exemplars_in_total[5m]))"
  }
}

resource "mimir_rule_group_recording" "mimir_received_exemplars" {
  name = "mimir_received_exemplars"

  rule {
    record = "cluster_namespace_job:cortex_distributor_received_exemplars:rate5m"
    expr   = "sum by (cluster, namespace, job) (rate(cortex_distributor_received_exemplars_total[5m]))"
  }
}

resource "mimir_rule_group_recording" "mimir_exemplars_ingested" {
  name = "mimir_exemplars_ingested"

  rule {
    record = "cluster_namespace_job:cortex_ingester_ingested_exemplars:rate5m"
    expr   = "sum by (cluster, namespace, job) (rate(cortex_ingester_ingested_exemplars_total[5m]))"
  }
}

resource "mimir_rule_group_recording" "mimir_exemplars_appended" {
  name = "mimir_exemplars_appended"

  rule {
    record = "cluster_namespace_job:cortex_ingester_tsdb_exemplar_exemplars_appended:rate5m"
    expr   = "sum by (cluster, namespace, job) (rate(cortex_ingester_tsdb_exemplar_exemplars_appended_total[5m]))"
  }
}

resource "mimir_rule_group_recording" "mimir_scaling_rules" {
  name = "mimir_scaling_rules"

  rule {
    record = "cluster_namespace_deployment:actual_replicas:count"

    expr = <<EOT
sum by (cluster, namespace, deployment) (
  label_replace(
    kube_deployment_spec_replicas,
    # The question mark in "(.*?)" is used to make it non-greedy, otherwise it
    # always matches everything and the (optional) zone is not removed.
    "deployment", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"
  )
)
or
sum by (cluster, namespace, deployment) (
  label_replace(kube_statefulset_replicas, "deployment", "$1", "statefulset", "(.*?)(?:-zone-[a-z])?")
)
EOT
  }

  rule {
    record = "cluster_namespace_deployment_reason:required_replicas:count"

    expr = <<EOT
ceil(
  quantile_over_time(0.99,
    sum by (cluster, namespace) (
      cluster_namespace_job:cortex_distributor_received_samples:rate5m
    )[24h:]
  )
  / 240000
)
EOT

    labels = {
      deployment = "distributor"
      reason     = "sample_rate"
    }
  }

  rule {
    record = "cluster_namespace_deployment_reason:required_replicas:count"

    expr = <<EOT
ceil(
  sum by (cluster, namespace) (cortex_limits_overrides{limit_name="ingestion_rate"})
  * 0.59999999999999998 / 240000
)
EOT

    labels = {
      deployment = "distributor"
      reason     = "sample_rate_limits"
    }
  }

  rule {
    record = "cluster_namespace_deployment_reason:required_replicas:count"

    expr = <<EOT
ceil(
  quantile_over_time(0.99,
    sum by (cluster, namespace) (
      cluster_namespace_job:cortex_distributor_received_samples:rate5m
    )[24h:]
  )
  * 3 / 80000
)
EOT

    labels = {
      deployment = "ingester"
      reason     = "sample_rate"
    }
  }

  rule {
    record = "cluster_namespace_deployment_reason:required_replicas:count"

    expr = <<EOT
ceil(
  quantile_over_time(0.99,
    sum by(cluster, namespace) (
      cortex_ingester_memory_series
    )[24h:]
  )
  / 1500000
)
EOT

    labels = {
      deployment = "ingester"
      reason     = "active_series"
    }
  }

  rule {
    record = "cluster_namespace_deployment_reason:required_replicas:count"

    expr = <<EOT
ceil(
  sum by (cluster, namespace) (cortex_limits_overrides{limit_name="max_global_series_per_user"})
  * 3 * 0.59999999999999998 / 1500000
)
EOT

    labels = {
      deployment = "ingester"
      reason     = "active_series_limits"
    }
  }

  rule {
    record = "cluster_namespace_deployment_reason:required_replicas:count"

    expr = <<EOT
ceil(
  sum by (cluster, namespace) (cortex_limits_overrides{limit_name="ingestion_rate"})
  * 0.59999999999999998 / 80000
)
EOT

    labels = {
      deployment = "ingester"
      reason     = "sample_rate_limits"
    }
  }

  rule {
    record = "cluster_namespace_deployment_reason:required_replicas:count"

    expr = <<EOT
ceil(
  (sum by (cluster, namespace) (
    cortex_ingester_tsdb_storage_blocks_bytes{job=~".+/ingester.*"}
  ) / 4)
    /
  avg by (cluster, namespace) (
    memcached_limit_bytes{job=~".+/memcached"}
  )
)
EOT

    labels = {
      deployment = "memcached"
      reason     = "active_series"
    }
  }

  rule {
    record = "cluster_namespace_deployment:container_cpu_usage_seconds_total:sum_rate"

    expr = <<EOT
sum by (cluster, namespace, deployment) (
  label_replace(
    label_replace(
      node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate,
      "deployment", "$1", "pod", "(.*)-(?:([0-9]+)|([a-z0-9]+)-([a-z0-9]+))"
    ),
    # The question mark in "(.*?)" is used to make it non-greedy, otherwise it
    # always matches everything and the (optional) zone is not removed.
    "deployment", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"
  )
)
EOT
  }

  rule {
    record = "cluster_namespace_deployment:kube_pod_container_resource_requests_cpu_cores:sum"

    expr = <<EOT
# This recording rule is made compatible with the breaking changes introduced in kube-state-metrics v2
# that remove resource metrics, ref:
# - https://github.com/kubernetes/kube-state-metrics/blob/master/CHANGELOG.md#v200-alpha--2020-09-16
# - https://github.com/kubernetes/kube-state-metrics/pull/1004
#
# This is the old expression, compatible with kube-state-metrics < v2.0.0,
# where kube_pod_container_resource_requests_cpu_cores was removed:
(
  sum by (cluster, namespace, deployment) (
    label_replace(
      label_replace(
        kube_pod_container_resource_requests_cpu_cores,
        "deployment", "$1", "pod", "(.*)-(?:([0-9]+)|([a-z0-9]+)-([a-z0-9]+))"
      ),
      # The question mark in "(.*?)" is used to make it non-greedy, otherwise it
      # always matches everything and the (optional) zone is not removed.
      "deployment", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"
    )
  )
)
or
# This expression is compatible with kube-state-metrics >= v1.4.0,
# where kube_pod_container_resource_requests was introduced.
(
  sum by (cluster, namespace, deployment) (
    label_replace(
      label_replace(
        kube_pod_container_resource_requests{resource="cpu"},
        "deployment", "$1", "pod", "(.*)-(?:([0-9]+)|([a-z0-9]+)-([a-z0-9]+))"
      ),
      # The question mark in "(.*?)" is used to make it non-greedy, otherwise it
      # always matches everything and the (optional) zone is not removed.
      "deployment", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"
    )
  )
)
EOT
  }

  rule {
    record = "cluster_namespace_deployment_reason:required_replicas:count"

    expr = <<EOT
ceil(
  cluster_namespace_deployment:actual_replicas:count
    *
  quantile_over_time(0.99, cluster_namespace_deployment:container_cpu_usage_seconds_total:sum_rate[24h])
    /
  cluster_namespace_deployment:kube_pod_container_resource_requests_cpu_cores:sum
)
EOT

    labels = {
      reason = "cpu_usage"
    }
  }

  rule {
    record = "cluster_namespace_deployment:container_memory_usage_bytes:sum"

    expr = <<EOT
sum by (cluster, namespace, deployment) (
  label_replace(
    label_replace(
      container_memory_usage_bytes{image!=""},
      "deployment", "$1", "pod", "(.*)-(?:([0-9]+)|([a-z0-9]+)-([a-z0-9]+))"
    ),
    # The question mark in "(.*?)" is used to make it non-greedy, otherwise it
    # always matches everything and the (optional) zone is not removed.
    "deployment", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"
  )
)
EOT
  }

  rule {
    record = "cluster_namespace_deployment:kube_pod_container_resource_requests_memory_bytes:sum"

    expr = <<EOT
# This recording rule is made compatible with the breaking changes introduced in kube-state-metrics v2
# that remove resource metrics, ref:
# - https://github.com/kubernetes/kube-state-metrics/blob/master/CHANGELOG.md#v200-alpha--2020-09-16
# - https://github.com/kubernetes/kube-state-metrics/pull/1004
#
# This is the old expression, compatible with kube-state-metrics < v2.0.0,
# where kube_pod_container_resource_requests_memory_bytes was removed:
(
  sum by (cluster, namespace, deployment) (
    label_replace(
      label_replace(
        kube_pod_container_resource_requests_memory_bytes,
        "deployment", "$1", "pod", "(.*)-(?:([0-9]+)|([a-z0-9]+)-([a-z0-9]+))"
      ),
      # The question mark in "(.*?)" is used to make it non-greedy, otherwise it
      # always matches everything and the (optional) zone is not removed.
      "deployment", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"
    )
  )
)
or
# This expression is compatible with kube-state-metrics >= v1.4.0,
# where kube_pod_container_resource_requests was introduced.
(
  sum by (cluster, namespace, deployment) (
    label_replace(
      label_replace(
        kube_pod_container_resource_requests{resource="memory"},
        "deployment", "$1", "pod", "(.*)-(?:([0-9]+)|([a-z0-9]+)-([a-z0-9]+))"
      ),
      # The question mark in "(.*?)" is used to make it non-greedy, otherwise it
      # always matches everything and the (optional) zone is not removed.
      "deployment", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"
    )
  )
)
EOT
  }

  rule {
    record = "cluster_namespace_deployment_reason:required_replicas:count"

    expr = <<EOT
ceil(
  cluster_namespace_deployment:actual_replicas:count
    *
  quantile_over_time(0.99, cluster_namespace_deployment:container_memory_usage_bytes:sum[24h])
    /
  cluster_namespace_deployment:kube_pod_container_resource_requests_memory_bytes:sum
)
EOT

    labels = {
      reason = "memory_usage"
    }
  }
}

resource "mimir_rule_group_recording" "mimir_alertmanager_rules" {
  name = "mimir_alertmanager_rules"

  rule {
    record = "cluster_job_pod:cortex_alertmanager_alerts:sum"
    expr   = "sum by (cluster, job, pod) (cortex_alertmanager_alerts)"
  }

  rule {
    record = "cluster_job_pod:cortex_alertmanager_silences:sum"
    expr   = "sum by (cluster, job, pod) (cortex_alertmanager_silences)"
  }

  rule {
    record = "cluster_job:cortex_alertmanager_alerts_received_total:rate5m"
    expr   = "sum by (cluster, job) (rate(cortex_alertmanager_alerts_received_total[5m]))"
  }

  rule {
    record = "cluster_job:cortex_alertmanager_alerts_invalid_total:rate5m"
    expr   = "sum by (cluster, job) (rate(cortex_alertmanager_alerts_invalid_total[5m]))"
  }

  rule {
    record = "cluster_job_integration:cortex_alertmanager_notifications_total:rate5m"
    expr   = "sum by (cluster, job, integration) (rate(cortex_alertmanager_notifications_total[5m]))"
  }

  rule {
    record = "cluster_job_integration:cortex_alertmanager_notifications_failed_total:rate5m"
    expr   = "sum by (cluster, job, integration) (rate(cortex_alertmanager_notifications_failed_total[5m]))"
  }

  rule {
    record = "cluster_job:cortex_alertmanager_state_replication_total:rate5m"
    expr   = "sum by (cluster, job) (rate(cortex_alertmanager_state_replication_total[5m]))"
  }

  rule {
    record = "cluster_job:cortex_alertmanager_state_replication_failed_total:rate5m"
    expr   = "sum by (cluster, job) (rate(cortex_alertmanager_state_replication_failed_total[5m]))"
  }

  rule {
    record = "cluster_job:cortex_alertmanager_partial_state_merges_total:rate5m"
    expr   = "sum by (cluster, job) (rate(cortex_alertmanager_partial_state_merges_total[5m]))"
  }

  rule {
    record = "cluster_job:cortex_alertmanager_partial_state_merges_failed_total:rate5m"
    expr   = "sum by (cluster, job) (rate(cortex_alertmanager_partial_state_merges_failed_total[5m]))"
  }
}

resource "mimir_rule_group_recording" "mimir_ingester_rules" {
  name = "mimir_ingester_rules"

  rule {
    record = "cluster_namespace_pod:cortex_ingester_ingested_samples_total:rate1m"
    expr   = "sum by(cluster, namespace, pod) (rate(cortex_ingester_ingested_samples_total[1m]))"
  }
}

