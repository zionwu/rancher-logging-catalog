version: '2'
services:
  logging-agent:
    privileged: true
    image: registry.cn-hangzhou.aliyuncs.com/zionwu/fluentd:v0.0.1 
    pid: host
    {{- if eq .Values.log_driver "journald" }}
    command:
    - fluentd
    - -c
    - /fluentd/etc/fluent-journald.conf
    volumes:
    - /run/log/journal:/run/log/journal
    {{- end }}
    external_links:
    - ${elasticsearch_source}:elasticsearch
    volumes_from:
    - logging-helper
    labels:
      io.rancher.container.pull_image: always
      io.rancher.scheduler.global: 'true'
      io.rancher.sidekicks: logging-helper
    logging:
      driver: json-file
      options:
        max-size: 25m
        max-file: '2'
  logging-helper:
    privileged: true
    image: registry.cn-hangzhou.aliyuncs.com/niusmallnan/logging-helper:v0.3.0
    environment:
      LOG_VOL_PATTERN: '${log_vol_pattern}'
      LOG_FILE_PATTERN: '${log_file_pattern}'
    volumes:
    - /var/lib/docker:/var/lib/docker
    - /var/log/logging-volumes:/var/log/logging-volumes
    - /var/log/logging-containers:/var/log/logging-containers
    - /var/run/docker.sock:/var/run/docker.sock
    pid: host
    labels:
      io.rancher.container.pull_image: always
    logging:
      driver: json-file
      options:
        max-size: 25m
        max-file: '2'
