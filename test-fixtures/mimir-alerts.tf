resource "mimir_rule_group_alerting" "mimir_alerts" {
  name = "mimir_alerts"

  rule {
    alert = "MimirIngesterUnhealthy"
    expr  = "min by (cluster, namespace) (cortex_ring_members{state=\"Unhealthy\", name=\"ingester\"}) > 0"
    for   = "15m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir cluster {{ $labels.cluster }}/{{ $labels.namespace }} has {{ printf \"%f\" $value }} unhealthy ingester(s)."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringesterunhealthy"
    }
  }

  rule {
    alert = "MimirRequestErrors"

    expr = <<EOT
100 * sum by (cluster, namespace, job, route) (rate(cortex_request_duration_seconds_count{status_code=~"5..",route!~"ready"}[1m]))
  /
sum by (cluster, namespace, job, route) (rate(cortex_request_duration_seconds_count{route!~"ready"}[1m]))
  > 1
EOT

    for = "15m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "The route {{ $labels.route }} in {{ $labels.cluster }}/{{ $labels.namespace }} is experiencing {{ printf \"%.2f\" $value }}% errors."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirrequesterrors"
    }
  }

  rule {
    alert = "MimirRequestLatency"

    expr = <<EOT
cluster_namespace_job_route:cortex_request_duration_seconds:99quantile{route!~"metrics|/frontend.Frontend/Process|ready|/schedulerpb.SchedulerForFrontend/FrontendLoop|/schedulerpb.SchedulerForQuerier/QuerierLoop"}
   >
2.5
EOT

    for = "15m"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "{{ $labels.job }} {{ $labels.route }} is experiencing {{ printf \"%.2f\" $value }}s 99th percentile latency."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirrequestlatency"
    }
  }

  rule {
    alert = "MimirQueriesIncorrect"

    expr = <<EOT
100 * sum by (cluster, namespace) (rate(test_exporter_test_case_result_total{result="fail"}[5m]))
  /
sum by (cluster, namespace) (rate(test_exporter_test_case_result_total[5m])) > 1
EOT

    for = "15m"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "The Mimir cluster {{ $labels.cluster }}/{{ $labels.namespace }} is experiencing {{ printf \"%.2f\" $value }}% incorrect query results."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirqueriesincorrect"
    }
  }

  rule {
    alert = "MimirInconsistentRuntimeConfig"
    expr  = "count(count by(cluster, namespace, job, sha256) (cortex_runtime_config_hash)) without(sha256) > 1"
    for   = "1h"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "An inconsistent runtime config file is used across cluster {{ $labels.cluster }}/{{ $labels.namespace }}."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirinconsistentruntimeconfig"
    }
  }

  rule {
    alert = "MimirBadRuntimeConfig"

    expr = <<EOT
# The metric value is reset to 0 on error while reloading the config at runtime.
cortex_runtime_config_last_reload_successful == 0
EOT

    for = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "{{ $labels.job }} failed to reload runtime config."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirbadruntimeconfig"
    }
  }

  rule {
    alert = "MimirFrontendQueriesStuck"
    expr  = "sum by (cluster, namespace, job) (min_over_time(cortex_query_frontend_queue_length[1m])) > 0"
    for   = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "There are {{ $value }} queued up queries in {{ $labels.cluster }}/{{ $labels.namespace }} {{ $labels.job }}."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirfrontendqueriesstuck"
    }
  }

  rule {
    alert = "MimirSchedulerQueriesStuck"
    expr  = "sum by (cluster, namespace, job) (min_over_time(cortex_query_scheduler_queue_length[1m])) > 0"
    for   = "7m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "There are {{ $value }} queued up queries in {{ $labels.cluster }}/{{ $labels.namespace }} {{ $labels.job }}."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirschedulerqueriesstuck"
    }
  }

  rule {
    alert = "MimirCacheRequestErrors"

    expr = <<EOT
(
  sum by(cluster, namespace, name, operation) (
    rate(thanos_memcached_operation_failures_total[1m])
    or
    rate(thanos_cache_operation_failures_total[1m])
  )
  /
  sum by(cluster, namespace, name, operation) (
    rate(thanos_memcached_operations_total[1m])
    or
    rate(thanos_cache_operations_total[1m])
  )
) * 100 > 5
EOT

    for = "5m"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "The cache {{ $labels.name }} used by Mimir {{ $labels.cluster }}/{{ $labels.namespace }} is experiencing {{ printf \"%.2f\" $value }}% errors for {{ $labels.operation }} operation."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimircacherequesterrors"
    }
  }

  rule {
    alert = "MimirIngesterRestarts"
    expr  = "changes(process_start_time_seconds{job=~\".*/(ingester.*|cortex|mimir|mimir-write.*)\"}[30m]) >= 2"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "{{ $labels.job }}/{{ $labels.pod }} has restarted {{ printf \"%.2f\" $value }} times in the last 30 mins."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringesterrestarts"
    }
  }

  rule {
    alert = "MimirKVStoreFailure"

    expr = <<EOT
(
  sum by(cluster, namespace, pod, status_code, kv_name) (rate(cortex_kv_request_duration_seconds_count{status_code!~"2.+"}[1m]))
  /
  sum by(cluster, namespace, pod, status_code, kv_name) (rate(cortex_kv_request_duration_seconds_count[1m]))
)
# We want to get alerted only in case there's a constant failure.
== 1
EOT

    for = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir {{ $labels.pod }} in  {{ $labels.cluster }}/{{ $labels.namespace }} is failing to talk to the KV store {{ $labels.kv_name }}."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirkvstorefailure"
    }
  }

  rule {
    alert = "MimirMemoryMapAreasTooHigh"
    expr  = "process_memory_map_areas{job=~\".*/(ingester.*|cortex|mimir|mimir-write.*|store-gateway.*|cortex|mimir|mimir-backend.*)\"} / process_memory_map_areas_limit{job=~\".*/(ingester.*|cortex|mimir|mimir-write.*|store-gateway.*|cortex|mimir|mimir-backend.*)\"} > 0.8"
    for   = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirmemorymapareastoohigh"
      message     = "{{ $labels.job }}/{{ $labels.pod }} has a number of mmap-ed areas close to the limit."
    }
  }

  rule {
    alert = "MimirDistributorForwardingErrorRate"

    expr = <<EOT
sum by (cluster, namespace) (rate(cortex_distributor_forward_errors_total{}[1m]))
/
sum by (cluster, namespace) (rate(cortex_distributor_forward_requests_total{}[1m]))
> 0.01
EOT

    for = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir in {{ $labels.cluster }}/{{ $labels.namespace }} has a high failure rate when forwarding samples."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirdistributorforwardingerrorrate"
    }
  }

  rule {
    alert = "MimirIngesterInstanceHasNoTenants"

    expr = <<EOT
(min by(cluster, namespace, pod) (cortex_ingester_memory_users) == 0)
and on (cluster, namespace)
# Only if there are more time-series than would be expected due to continuous testing load
(
  sum by(cluster, namespace) (cortex_ingester_memory_series)
  /
  max by(cluster, namespace) (cortex_distributor_replication_factor)
) > 100000
EOT

    for = "1h"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Mimir ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} has no tenants assigned."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringesterinstancehasnotenants"
    }
  }

  rule {
    alert = "MimirRulerInstanceHasNoRuleGroups"

    expr = <<EOT
# Alert on ruler instances in microservices mode that have no rule groups assigned,
min by(cluster, namespace, pod) (cortex_ruler_managers_total{pod=~"(.*mimir-)?ruler.*"}) == 0
# but only if other ruler instances of the same cell do have rule groups assigned
and on (cluster, namespace)
(max by(cluster, namespace) (cortex_ruler_managers_total) > 0)
# and there are more than two instances overall
and on (cluster, namespace)
(count by (cluster, namespace) (cortex_ruler_managers_total) > 2)
EOT

    for = "1h"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Mimir ruler {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} has no rule groups assigned."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirrulerinstancehasnorulegroups"
    }
  }

  rule {
    alert = "MimirRingMembersMismatch"

    expr = <<EOT
(
  avg by(cluster, namespace) (sum by(cluster, namespace, pod) (cortex_ring_members{name="ingester",job=~".*/(ingester.*|cortex|mimir|mimir-write.*)"}))
  != sum by(cluster, namespace) (up{job=~".*/(ingester.*|cortex|mimir|mimir-write.*)"})
)
and
(
  count by(cluster, namespace) (cortex_build_info) > 0
)
EOT

    for = "15m"

    labels = {
      component = "ingester"
      severity  = "warning"
    }

    annotations = {
      message     = "Number of members in Mimir ingester hash ring does not match the expected number in {{ $labels.cluster }}/{{ $labels.namespace }}."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirringmembersmismatch"
    }
  }
}

resource "mimir_rule_group_alerting" "mimir_instance_limits_alerts" {
  name = "mimir_instance_limits_alerts"

  rule {
    alert = "MimirIngesterReachingSeriesLimit"

    expr = <<EOT
(
    (cortex_ingester_memory_series / ignoring(limit) cortex_ingester_instance_limits{limit="max_series"})
    and ignoring (limit)
    (cortex_ingester_instance_limits{limit="max_series"} > 0)
) > 0.8
EOT

    for = "3h"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Ingester {{ $labels.job }}/{{ $labels.pod }} has reached {{ $value | humanizePercentage }} of its series limit."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringesterreachingserieslimit"
    }
  }

  rule {
    alert = "MimirIngesterReachingSeriesLimit"

    expr = <<EOT
(
    (cortex_ingester_memory_series / ignoring(limit) cortex_ingester_instance_limits{limit="max_series"})
    and ignoring (limit)
    (cortex_ingester_instance_limits{limit="max_series"} > 0)
) > 0.9
EOT

    for = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Ingester {{ $labels.job }}/{{ $labels.pod }} has reached {{ $value | humanizePercentage }} of its series limit."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringesterreachingserieslimit"
    }
  }

  rule {
    alert = "MimirIngesterReachingTenantsLimit"

    expr = <<EOT
(
    (cortex_ingester_memory_users / ignoring(limit) cortex_ingester_instance_limits{limit="max_tenants"})
    and ignoring (limit)
    (cortex_ingester_instance_limits{limit="max_tenants"} > 0)
) > 0.7
EOT

    for = "5m"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Ingester {{ $labels.job }}/{{ $labels.pod }} has reached {{ $value | humanizePercentage }} of its tenant limit."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringesterreachingtenantslimit"
    }
  }

  rule {
    alert = "MimirIngesterReachingTenantsLimit"

    expr = <<EOT
(
    (cortex_ingester_memory_users / ignoring(limit) cortex_ingester_instance_limits{limit="max_tenants"})
    and ignoring (limit)
    (cortex_ingester_instance_limits{limit="max_tenants"} > 0)
) > 0.8
EOT

    for = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Ingester {{ $labels.job }}/{{ $labels.pod }} has reached {{ $value | humanizePercentage }} of its tenant limit."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringesterreachingtenantslimit"
    }
  }

  rule {
    alert = "MimirReachingTCPConnectionsLimit"

    expr = <<EOT
cortex_tcp_connections / cortex_tcp_connections_limit > 0.8 and
cortex_tcp_connections_limit > 0
EOT

    for = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirreachingtcpconnectionslimit"
      message     = "Mimir instance {{ $labels.job }}/{{ $labels.pod }} has reached {{ $value | humanizePercentage }} of its TCP connections limit for {{ $labels.protocol }} protocol."
    }
  }

  rule {
    alert = "MimirDistributorReachingInflightPushRequestLimit"

    expr = <<EOT
(
    (cortex_distributor_inflight_push_requests / ignoring(limit) cortex_distributor_instance_limits{limit="max_inflight_push_requests"})
    and ignoring (limit)
    (cortex_distributor_instance_limits{limit="max_inflight_push_requests"} > 0)
) > 0.8
EOT

    for = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Distributor {{ $labels.job }}/{{ $labels.pod }} has reached {{ $value | humanizePercentage }} of its inflight push request limit."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirdistributorreachinginflightpushrequestlimit"
    }
  }
}

resource "mimir_rule_group_alerting" "mimir-rollout-alerts" {
  name = "mimir-rollout-alerts"

  rule {
    alert = "MimirRolloutStuck"

    expr = <<EOT
(
  max without (revision) (
    sum without(statefulset) (label_replace(kube_statefulset_status_current_revision, "rollout_group", "$1", "statefulset", "(.*?)(?:-zone-[a-z])?"))
      unless
    sum without(statefulset) (label_replace(kube_statefulset_status_update_revision, "rollout_group", "$1", "statefulset", "(.*?)(?:-zone-[a-z])?"))
  )
    *
  (
    sum without(statefulset) (label_replace(kube_statefulset_replicas, "rollout_group", "$1", "statefulset", "(.*?)(?:-zone-[a-z])?"))
      !=
    sum without(statefulset) (label_replace(kube_statefulset_status_replicas_updated, "rollout_group", "$1", "statefulset", "(.*?)(?:-zone-[a-z])?"))
  )
) and (
  changes(sum without(statefulset) (label_replace(kube_statefulset_status_replicas_updated, "rollout_group", "$1", "statefulset", "(.*?)(?:-zone-[a-z])?"))[15m:1m])
    ==
  0
)
* on(cluster, namespace) group_left max by(cluster, namespace) (cortex_build_info)
EOT

    for = "30m"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "The {{ $labels.rollout_group }} rollout is stuck in {{ $labels.cluster }}/{{ $labels.namespace }}."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirrolloutstuck"
    }
  }

  rule {
    alert = "MimirRolloutStuck"

    expr = <<EOT
(
  sum without(deployment) (label_replace(kube_deployment_spec_replicas, "rollout_group", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"))
    !=
  sum without(deployment) (label_replace(kube_deployment_status_replicas_updated, "rollout_group", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"))
) and (
  changes(sum without(deployment) (label_replace(kube_deployment_status_replicas_updated, "rollout_group", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"))[15m:1m])
    ==
  0
)
* on(cluster, namespace) group_left max by(cluster, namespace) (cortex_build_info)
EOT

    for = "30m"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "The {{ $labels.rollout_group }} rollout is stuck in {{ $labels.cluster }}/{{ $labels.namespace }}."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirrolloutstuck"
    }
  }

  rule {
    alert = "RolloutOperatorNotReconciling"
    expr  = "max by(cluster, namespace, rollout_group) (time() - rollout_operator_last_successful_group_reconcile_timestamp_seconds) > 600"
    for   = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Rollout operator is not reconciling the rollout group {{ $labels.rollout_group }} in {{ $labels.cluster }}/{{ $labels.namespace }}."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#rolloutoperatornotreconciling"
    }
  }
}

resource "mimir_rule_group_alerting" "mimir-provisioning" {
  name = "mimir-provisioning"

  rule {
    alert = "MimirProvisioningTooManyActiveSeries"
    expr  = "avg by (cluster, namespace) (cortex_ingester_memory_series) > 1.6e6"
    for   = "2h"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "The number of in-memory series per ingester in {{ $labels.cluster }}/{{ $labels.namespace }} is too high."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirprovisioningtoomanyactiveseries"
    }
  }

  rule {
    alert = "MimirProvisioningTooManyWrites"
    expr  = "avg by (cluster, namespace) (cluster_namespace_pod:cortex_ingester_ingested_samples_total:rate1m) > 80e3"
    for   = "15m"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Ingesters in {{ $labels.cluster }}/{{ $labels.namespace }} ingest too many samples per second."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirprovisioningtoomanywrites"
    }
  }

  rule {
    alert = "MimirAllocatingTooMuchMemory"

    expr = <<EOT
(
  # We use RSS instead of working set memory because of the ingester's extensive usage of mmap.
  # See: https://github.com/grafana/mimir/issues/2466
  container_memory_rss{container=~"(ingester|mimir-write|mimir-backend)"}
    /
  ( container_spec_memory_limit_bytes{container=~"(ingester|mimir-write|mimir-backend)"} > 0 )
) > 0.65
EOT

    for = "15m"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Instance {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is using too much memory."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirallocatingtoomuchmemory"
    }
  }

  rule {
    alert = "MimirAllocatingTooMuchMemory"

    expr = <<EOT
(
  # We use RSS instead of working set memory because of the ingester's extensive usage of mmap.
  # See: https://github.com/grafana/mimir/issues/2466
  container_memory_rss{container=~"(ingester|mimir-write|mimir-backend)"}
    /
  ( container_spec_memory_limit_bytes{container=~"(ingester|mimir-write|mimir-backend)"} > 0 )
) > 0.8
EOT

    for = "15m"

    labels = {
      severity = "critical"
    }

    annotations = {
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirallocatingtoomuchmemory"
      message     = "Instance {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is using too much memory."
    }
  }
}

resource "mimir_rule_group_alerting" "ruler_alerts" {
  name = "ruler_alerts"

  rule {
    alert = "MimirRulerTooManyFailedPushes"

    expr = <<EOT
100 * (
sum by (cluster, namespace, pod) (rate(cortex_ruler_write_requests_failed_total[1m]))
  /
sum by (cluster, namespace, pod) (rate(cortex_ruler_write_requests_total[1m]))
) > 1
EOT

    for = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Ruler {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is experiencing {{ printf \"%.2f\" $value }}% write (push) errors."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirrulertoomanyfailedpushes"
    }
  }

  rule {
    alert = "MimirRulerTooManyFailedQueries"

    expr = <<EOT
100 * (
sum by (cluster, namespace, pod) (rate(cortex_ruler_queries_failed_total[1m]))
  /
sum by (cluster, namespace, pod) (rate(cortex_ruler_queries_total[1m]))
) > 1
EOT

    for = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Ruler {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is experiencing {{ printf \"%.2f\" $value }}% errors while evaluating rules."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirrulertoomanyfailedqueries"
    }
  }

  rule {
    alert = "MimirRulerMissedEvaluations"

    expr = <<EOT
100 * (
sum by (cluster, namespace, pod, rule_group) (rate(cortex_prometheus_rule_group_iterations_missed_total[1m]))
  /
sum by (cluster, namespace, pod, rule_group) (rate(cortex_prometheus_rule_group_iterations_total[1m]))
) > 1
EOT

    for = "5m"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Mimir Ruler {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is experiencing {{ printf \"%.2f\" $value }}% missed iterations for the rule group {{ $labels.rule_group }}."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirrulermissedevaluations"
    }
  }

  rule {
    alert = "MimirRulerFailedRingCheck"

    expr = <<EOT
sum by (cluster, namespace, job) (rate(cortex_ruler_ring_check_errors_total[1m]))
   > 0
EOT

    for = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Rulers in {{ $labels.cluster }}/{{ $labels.namespace }} are experiencing errors when checking the ring for rule group ownership."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirrulerfailedringcheck"
    }
  }

  rule {
    alert = "MimirRulerRemoteEvaluationFailing"

    expr = <<EOT
100 * (
sum by (cluster, namespace) (rate(cortex_request_duration_seconds_count{route="/httpgrpc.HTTP/Handle", status_code=~"5..", job=~".*/(ruler-query-frontend.*)"}[5m]))
  /
sum by (cluster, namespace) (rate(cortex_request_duration_seconds_count{route="/httpgrpc.HTTP/Handle", job=~".*/(ruler-query-frontend.*)"}[5m]))
) > 1
EOT

    for = "5m"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Mimir rulers in {{ $labels.cluster }}/{{ $labels.namespace }} are failing to perform {{ printf \"%.2f\" $value }}% of remote evaluations through the ruler-query-frontend."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirrulerremoteevaluationfailing"
    }
  }
}

resource "mimir_rule_group_alerting" "gossip_alerts" {
  name = "gossip_alerts"

  rule {
    alert = "MimirGossipMembersMismatch"
    expr  = "avg by (cluster, namespace) (memberlist_client_cluster_members_count) != sum by (cluster, namespace) (up{job=~\".+/(alertmanager|compactor|distributor|ingester.*|querier.*|ruler|ruler-querier.*|store-gateway.*|cortex|mimir|mimir-write.*|mimir-read.*|mimir-backend.*)\"})"
    for   = "15m"

    labels = {
      severity = "warning"
    }

    annotations = {
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirgossipmembersmismatch"
      message     = "Mimir instance {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} sees incorrect number of gossip members."
    }
  }
}

resource "mimir_rule_group_alerting" "etcd_alerts" {
  name = "etcd_alerts"

  rule {
    alert = "EtcdAllocatingTooMuchMemory"

    expr = <<EOT
(
  container_memory_working_set_bytes{container="etcd"}
    /
  ( container_spec_memory_limit_bytes{container="etcd"} > 0 )
) > 0.65
EOT

    for = "15m"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Too much memory being used by {{ $labels.namespace }}/{{ $labels.pod }} - bump memory limit."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#etcdallocatingtoomuchmemory"
    }
  }

  rule {
    alert = "EtcdAllocatingTooMuchMemory"

    expr = <<EOT
(
  container_memory_working_set_bytes{container="etcd"}
    /
  ( container_spec_memory_limit_bytes{container="etcd"} > 0 )
) > 0.8
EOT

    for = "15m"

    labels = {
      severity = "critical"
    }

    annotations = {
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#etcdallocatingtoomuchmemory"
      message     = "Too much memory being used by {{ $labels.namespace }}/{{ $labels.pod }} - bump memory limit."
    }
  }
}

resource "mimir_rule_group_alerting" "alertmanager_alerts" {
  name = "alertmanager_alerts"

  rule {
    alert = "MimirAlertmanagerSyncConfigsFailing"
    expr  = "rate(cortex_alertmanager_sync_configs_failed_total[5m]) > 0"
    for   = "30m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Alertmanager {{ $labels.job }}/{{ $labels.pod }} is failing to read tenant configurations from storage."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiralertmanagersyncconfigsfailing"
    }
  }

  rule {
    alert = "MimirAlertmanagerRingCheckFailing"
    expr  = "rate(cortex_alertmanager_ring_check_errors_total[2m]) > 0"
    for   = "10m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Alertmanager {{ $labels.job }}/{{ $labels.pod }} is unable to check tenants ownership via the ring."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiralertmanagerringcheckfailing"
    }
  }

  rule {
    alert = "MimirAlertmanagerPartialStateMergeFailing"
    expr  = "rate(cortex_alertmanager_partial_state_merges_failed_total[2m]) > 0"
    for   = "10m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Alertmanager {{ $labels.job }}/{{ $labels.pod }} is failing to merge partial state changes received from a replica."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiralertmanagerpartialstatemergefailing"
    }
  }

  rule {
    alert = "MimirAlertmanagerReplicationFailing"
    expr  = "rate(cortex_alertmanager_state_replication_failed_total[2m]) > 0"
    for   = "10m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Alertmanager {{ $labels.job }}/{{ $labels.pod }} is failing to replicating partial state to its replicas."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiralertmanagerreplicationfailing"
    }
  }

  rule {
    alert = "MimirAlertmanagerPersistStateFailing"
    expr  = "rate(cortex_alertmanager_state_persist_failed_total[15m]) > 0"
    for   = "1h"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Alertmanager {{ $labels.job }}/{{ $labels.pod }} is unable to persist full state snaphots to remote storage."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiralertmanagerpersiststatefailing"
    }
  }

  rule {
    alert = "MimirAlertmanagerInitialSyncFailed"
    expr  = "increase(cortex_alertmanager_state_initial_sync_completed_total{outcome=\"failed\"}[1m]) > 0"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Alertmanager {{ $labels.job }}/{{ $labels.pod }} was unable to obtain some initial state when starting up."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiralertmanagerinitialsyncfailed"
    }
  }

  rule {
    alert = "MimirAlertmanagerAllocatingTooMuchMemory"

    expr = <<EOT
(container_memory_working_set_bytes{container="alertmanager"} / container_spec_memory_limit_bytes{container="alertmanager"}) > 0.80
and
(container_spec_memory_limit_bytes{container="alertmanager"} > 0)
EOT

    for = "15m"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Alertmanager {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is using too much memory."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiralertmanagerallocatingtoomuchmemory"
    }
  }

  rule {
    alert = "MimirAlertmanagerAllocatingTooMuchMemory"

    expr = <<EOT
(container_memory_working_set_bytes{container="alertmanager"} / container_spec_memory_limit_bytes{container="alertmanager"}) > 0.90
and
(container_spec_memory_limit_bytes{container="alertmanager"} > 0)
EOT

    for = "15m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Alertmanager {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is using too much memory."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiralertmanagerallocatingtoomuchmemory"
    }
  }

  rule {
    alert = "MimirAlertmanagerInstanceHasNoTenants"

    expr = <<EOT
# Alert on alertmanager instances in microservices mode that own no tenants,
min by(cluster, namespace, pod) (cortex_alertmanager_tenants_owned{pod=~"(.*mimir-)?alertmanager.*"}) == 0
# but only if other instances of the same cell do have tenants assigned.
and on (cluster, namespace)
max by(cluster, namespace) (cortex_alertmanager_tenants_owned) > 0
EOT

    for = "1h"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Mimir alertmanager {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} owns no tenants."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiralertmanagerinstancehasnotenants"
    }
  }
}

resource "mimir_rule_group_alerting" "mimir_blocks_alerts" {
  name = "mimir_blocks_alerts"

  rule {
    alert = "MimirIngesterHasNotShippedBlocks"

    expr = <<EOT
(min by(cluster, namespace, pod) (time() - thanos_shipper_last_successful_upload_time) > 60 * 60 * 4)
and
(max by(cluster, namespace, pod) (thanos_shipper_last_successful_upload_time) > 0)
and
# Only if the ingester has ingested samples over the last 4h.
(max by(cluster, namespace, pod) (max_over_time(cluster_namespace_pod:cortex_ingester_ingested_samples_total:rate1m[4h])) > 0)
and
# Only if the ingester was ingesting samples 4h ago. This protects against the case where the ingester replica
# had ingested samples in the past, then no traffic was received for a long period and then it starts
# receiving samples again. Without this check, the alert would fire as soon as it gets back receiving
# samples, while the a block shipping is expected within the next 4h.
(max by(cluster, namespace, pod) (max_over_time(cluster_namespace_pod:cortex_ingester_ingested_samples_total:rate1m[1h] offset 4h)) > 0)
EOT

    for = "15m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} has not shipped any block in the last 4 hours."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringesterhasnotshippedblocks"
    }
  }

  rule {
    alert = "MimirIngesterHasNotShippedBlocksSinceStart"

    expr = <<EOT
(max by(cluster, namespace, pod) (thanos_shipper_last_successful_upload_time) == 0)
and
(max by(cluster, namespace, pod) (max_over_time(cluster_namespace_pod:cortex_ingester_ingested_samples_total:rate1m[4h])) > 0)
EOT

    for = "4h"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} has not shipped any block in the last 4 hours."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringesterhasnotshippedblockssincestart"
    }
  }

  rule {
    alert = "MimirIngesterHasUnshippedBlocks"

    expr = <<EOT
(time() - cortex_ingester_oldest_unshipped_block_timestamp_seconds > 3600)
and
(cortex_ingester_oldest_unshipped_block_timestamp_seconds > 0)
EOT

    for = "15m"

    labels = {
      severity = "critical"
    }

    annotations = {
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringesterhasunshippedblocks"
      message     = "Mimir Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} has compacted a block {{ $value | humanizeDuration }} ago but it hasn't been successfully uploaded to the storage yet."
    }
  }

  rule {
    alert = "MimirIngesterTSDBHeadCompactionFailed"
    expr  = "rate(cortex_ingester_tsdb_compactions_failed_total[5m]) > 0"
    for   = "15m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is failing to compact TSDB head."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringestertsdbheadcompactionfailed"
    }
  }

  rule {
    alert = "MimirIngesterTSDBHeadTruncationFailed"
    expr  = "rate(cortex_ingester_tsdb_head_truncations_failed_total[5m]) > 0"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is failing to truncate TSDB head."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringestertsdbheadtruncationfailed"
    }
  }

  rule {
    alert = "MimirIngesterTSDBCheckpointCreationFailed"
    expr  = "rate(cortex_ingester_tsdb_checkpoint_creations_failed_total[5m]) > 0"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is failing to create TSDB checkpoint."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringestertsdbcheckpointcreationfailed"
    }
  }

  rule {
    alert = "MimirIngesterTSDBCheckpointDeletionFailed"
    expr  = "rate(cortex_ingester_tsdb_checkpoint_deletions_failed_total[5m]) > 0"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is failing to delete TSDB checkpoint."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringestertsdbcheckpointdeletionfailed"
    }
  }

  rule {
    alert = "MimirIngesterTSDBWALTruncationFailed"
    expr  = "rate(cortex_ingester_tsdb_wal_truncations_failed_total[5m]) > 0"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Mimir Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is failing to truncate TSDB WAL."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringestertsdbwaltruncationfailed"
    }
  }

  rule {
    alert = "MimirIngesterTSDBWALCorrupted"
    expr  = "rate(cortex_ingester_tsdb_wal_corruptions_total[5m]) > 0"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} got a corrupted TSDB WAL."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringestertsdbwalcorrupted"
    }
  }

  rule {
    alert = "MimirIngesterTSDBWALWritesFailed"
    expr  = "rate(cortex_ingester_tsdb_wal_writes_failed_total[1m]) > 0"
    for   = "3m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is failing to write to TSDB WAL."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimiringestertsdbwalwritesfailed"
    }
  }

  rule {
    alert = "MimirQuerierHasNotScanTheBucket"

    expr = <<EOT
(time() - cortex_querier_blocks_last_successful_scan_timestamp_seconds > 60 * 30)
and
cortex_querier_blocks_last_successful_scan_timestamp_seconds > 0
EOT

    for = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Querier {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} has not successfully scanned the bucket since {{ $value | humanizeDuration }}."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirquerierhasnotscanthebucket"
    }
  }

  rule {
    alert = "MimirQuerierHighRefetchRate"

    expr = <<EOT
100 * (
  (
    sum by(cluster, namespace) (rate(cortex_querier_storegateway_refetches_per_query_count[5m]))
    -
    sum by(cluster, namespace) (rate(cortex_querier_storegateway_refetches_per_query_bucket{le="0.0"}[5m]))
  )
  /
  sum by(cluster, namespace) (rate(cortex_querier_storegateway_refetches_per_query_count[5m]))
)
> 1
EOT

    for = "10m"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Mimir Queries in {{ $labels.cluster }}/{{ $labels.namespace }} are refetching series from different store-gateways (because of missing blocks) for the {{ printf \"%.0f\" $value }}% of queries."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirquerierhighrefetchrate"
    }
  }

  rule {
    alert = "MimirStoreGatewayHasNotSyncTheBucket"

    expr = <<EOT
(time() - cortex_bucket_stores_blocks_last_successful_sync_timestamp_seconds{component="store-gateway"} > 60 * 30)
and
cortex_bucket_stores_blocks_last_successful_sync_timestamp_seconds{component="store-gateway"} > 0
EOT

    for = "5m"

    labels = {
      severity = "critical"
    }

    annotations = {
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirstoregatewayhasnotsyncthebucket"
      message     = "Mimir store-gateway {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} has not successfully synched the bucket since {{ $value | humanizeDuration }}."
    }
  }

  rule {
    alert = "MimirStoreGatewayNoSyncedTenants"
    expr  = "min by(cluster, namespace, pod) (cortex_bucket_stores_tenants_synced{component=\"store-gateway\"}) == 0"
    for   = "1h"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Mimir store-gateway {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is not syncing any blocks for any tenant."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirstoregatewaynosyncedtenants"
    }
  }

  rule {
    alert = "MimirBucketIndexNotUpdated"
    expr  = "min by(cluster, namespace, user) (time() - cortex_bucket_index_last_successful_update_timestamp_seconds) > 7200"

    labels = {
      severity = "critical"
    }

    annotations = {
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirbucketindexnotupdated"
      message     = "Mimir bucket index for tenant {{ $labels.user }} in {{ $labels.cluster }}/{{ $labels.namespace }} has not been updated since {{ $value | humanizeDuration }}."
    }
  }

  rule {
    alert = "MimirTenantHasPartialBlocks"
    expr  = "max by(cluster, namespace, user) (cortex_bucket_blocks_partials_count) > 0"
    for   = "6h"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Mimir tenant {{ $labels.user }} in {{ $labels.cluster }}/{{ $labels.namespace }} has {{ $value }} partial blocks."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirtenanthaspartialblocks"
    }
  }
}

resource "mimir_rule_group_alerting" "mimir_compactor_alerts" {
  name = "mimir_compactor_alerts"

  rule {
    alert = "MimirCompactorHasNotSuccessfullyCleanedUpBlocks"

    expr = <<EOT
# The "last successful run" metric is updated even if the compactor owns no tenants,
# so this alert correctly doesn't fire if compactor has nothing to do.
(time() - cortex_compactor_block_cleanup_last_successful_run_timestamp_seconds > 60 * 60 * 6)
EOT

    for = "1h"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Compactor {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} has not successfully cleaned up blocks in the last 6 hours."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimircompactorhasnotsuccessfullycleanedupblocks"
    }
  }

  rule {
    alert = "MimirCompactorHasNotSuccessfullyRunCompaction"

    expr = <<EOT
# The "last successful run" metric is updated even if the compactor owns no tenants,
# so this alert correctly doesn't fire if compactor has nothing to do.
(time() - cortex_compactor_last_successful_run_timestamp_seconds > 60 * 60 * 24)
and
(cortex_compactor_last_successful_run_timestamp_seconds > 0)
EOT

    for = "1h"

    labels = {
      reason   = "in-last-24h"
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Compactor {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} has not run compaction in the last 24 hours."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimircompactorhasnotsuccessfullyruncompaction"
    }
  }

  rule {
    alert = "MimirCompactorHasNotSuccessfullyRunCompaction"

    expr = <<EOT
# The "last successful run" metric is updated even if the compactor owns no tenants,
# so this alert correctly doesn't fire if compactor has nothing to do.
cortex_compactor_last_successful_run_timestamp_seconds == 0
EOT

    for = "1d"

    labels = {
      reason   = "since-startup"
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Compactor {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} has not run compaction in the last 24 hours."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimircompactorhasnotsuccessfullyruncompaction"
    }
  }

  rule {
    alert = "MimirCompactorHasNotSuccessfullyRunCompaction"
    expr  = "increase(cortex_compactor_runs_failed_total{reason!=\"shutdown\"}[2h]) >= 2"

    labels = {
      reason   = "consecutive-failures"
      severity = "critical"
    }

    annotations = {
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimircompactorhasnotsuccessfullyruncompaction"
      message     = "Mimir Compactor {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} failed to run 2 consecutive compactions."
    }
  }

  rule {
    alert = "MimirCompactorHasNotUploadedBlocks"

    expr = <<EOT
(time() - (max by(cluster, namespace, pod) (thanos_objstore_bucket_last_successful_upload_time{component="compactor"})) > 60 * 60 * 24)
and
(max by(cluster, namespace, pod) (thanos_objstore_bucket_last_successful_upload_time{component="compactor"}) > 0)
and
# Only if some compactions have started. We don't want to fire this alert if the compactor has nothing to do
# (e.g. there are more replicas than required because running as part of mimir-backend).
(sum by(cluster, namespace, pod) (rate(cortex_compactor_group_compaction_runs_started_total[24h])) > 0)
EOT

    for = "15m"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Compactor {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} has not uploaded any block in the last 24 hours."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimircompactorhasnotuploadedblocks"
    }
  }

  rule {
    alert = "MimirCompactorHasNotUploadedBlocks"

    expr = <<EOT
(max by(cluster, namespace, pod) (thanos_objstore_bucket_last_successful_upload_time{component="compactor"}) == 0)
and
# Only if some compactions have started. We don't want to fire this alert if the compactor has nothing to do
# (e.g. there are more replicas than required because running as part of mimir-backend).
(sum by(cluster, namespace, pod) (rate(cortex_compactor_group_compaction_runs_started_total[24h])) > 0)
EOT

    for = "1d"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "Mimir Compactor {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} has not uploaded any block in the last 24 hours."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimircompactorhasnotuploadedblocks"
    }
  }

  rule {
    alert = "MimirCompactorSkippedBlocksWithOutOfOrderChunks"
    expr  = "increase(cortex_compactor_blocks_marked_for_no_compaction_total{reason=\"block-index-out-of-order-chunk\"}[5m]) > 0"
    for   = "1m"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Mimir Compactor {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} has found and ignored blocks with out of order chunks."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimircompactorskippedblockswithoutoforderchunks"
    }
  }
}

resource "mimir_rule_group_alerting" "mimir_autoscaling" {
  name = "mimir_autoscaling"

  rule {
    alert = "MimirAutoscalerNotActive"

    expr = <<EOT
(
    kube_horizontalpodautoscaler_status_condition{condition="ScalingActive",status="false"}
    # Match only Mimir namespaces.
    * on(cluster, namespace) group_left max by(cluster, namespace) (cortex_build_info)
    # Add "metric" label.
    + on(cluster, namespace, horizontalpodautoscaler) group_right label_replace(kube_horizontalpodautoscaler_spec_target_metric*0, "metric", "$1", "metric_name", "(.+)")
    > 0
)
# Alert only if the scaling metric exists and is > 0. If the KEDA ScaledObject is configured to scale down 0,
# then HPA ScalingActive may be false when expected to run 0 replicas. In this case, the scaling metric exported
# by KEDA could not exist at all or being exposed with a value of 0.
and on (cluster, namespace, metric)
(label_replace(keda_metrics_adapter_scaler_metrics_value, "namespace", "$0", "exported_namespace", ".+") > 0)
EOT

    for = "1h"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "The Horizontal Pod Autoscaler (HPA) {{ $labels.horizontalpodautoscaler }} in {{ $labels.namespace }} is not active."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirautoscalernotactive"
    }
  }

  rule {
    alert = "MimirAutoscalerKedaFailing"

    expr = <<EOT
(
    # Find KEDA scalers reporting errors.
    label_replace(rate(keda_metrics_adapter_scaler_errors[5m]), "namespace", "$1", "exported_namespace", "(.*)")
    # Match only Mimir namespaces.
    * on(cluster, namespace) group_left max by(cluster, namespace) (cortex_build_info)
)
> 0
EOT

    for = "1h"

    labels = {
      severity = "critical"
    }

    annotations = {
      message     = "The Keda ScaledObject {{ $labels.scaledObject }} in {{ $labels.namespace }} is experiencing errors."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimirautoscalerkedafailing"
    }
  }
}

resource "mimir_rule_group_alerting" "mimir_continuous_test" {
  name = "mimir_continuous_test"

  rule {
    alert = "MimirContinuousTestNotRunningOnWrites"
    expr  = "sum by(cluster, namespace, test) (rate(mimir_continuous_test_writes_failed_total[5m])) > 0"
    for   = "1h"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Mimir continuous test {{ $labels.test }} in {{ $labels.cluster }}/{{ $labels.namespace }} is not effectively running because writes are failing."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimircontinuoustestnotrunningonwrites"
    }
  }

  rule {
    alert = "MimirContinuousTestNotRunningOnReads"
    expr  = "sum by(cluster, namespace, test) (rate(mimir_continuous_test_queries_failed_total[5m])) > 0"
    for   = "1h"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Mimir continuous test {{ $labels.test }} in {{ $labels.cluster }}/{{ $labels.namespace }} is not effectively running because queries are failing."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimircontinuoustestnotrunningonreads"
    }
  }

  rule {
    alert = "MimirContinuousTestFailed"
    expr  = "sum by(cluster, namespace, test) (rate(mimir_continuous_test_query_result_checks_failed_total[10m])) > 0"

    labels = {
      severity = "warning"
    }

    annotations = {
      message     = "Mimir continuous test {{ $labels.test }} in {{ $labels.cluster }}/{{ $labels.namespace }} failed when asserting query results."
      runbook_url = "https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#mimircontinuoustestfailed"
    }
  }
}

