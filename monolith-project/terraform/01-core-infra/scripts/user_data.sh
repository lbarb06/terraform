#!/bin/bash
set -euxo pipefail

dnf update -y
dnf install -y nginx

cat >/usr/share/nginx/html/index.html <<HTML
<!doctype html>
<html>
  <head><title>Web App</title></head>
  <body>
    <h1>Web App Running</h1>
    <p>Database endpoint: ${db_host}</p>
  </body>
</html>
HTML

systemctl enable nginx
systemctl start nginx

if [ "${enable_log_shipping}" = "true" ]; then
  dnf install -y amazon-cloudwatch-agent

  cat >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<CWAGENT
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/nginx-access",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/nginx-error",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/messages",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/system-messages",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/cloud-init",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
CWAGENT

  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s
fi
