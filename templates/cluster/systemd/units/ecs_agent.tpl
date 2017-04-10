[Unit]
Description=The AWS ECS agent
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
TimeoutStopSec=0
Restart=on-failure
RestartSec=30
SyslogIdentifier=ecs-agent
ExecStartPre=-/bin/mkdir -p /var/ecs-data
ExecStartPre=-/usr/bin/docker stop ecs-agent
ExecStartPre=-/usr/bin/docker pull amazon/amazon-ecs-agent:v1.14.1
ExecStartPre=-/usr/bin/docker rm ecs-agent
ExecStart=/usr/bin/docker run --name ecs-agent \
    --env-file /etc/ecs/ecs.config \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/ecs-data:/data \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    -v /run/docker/execdriver/native:/run/docker/execdriver/native:ro \
    -p 51678:51678 \
    amazon/amazon-ecs-agent:v1.14.1
ExecStop=/usr/bin/docker stop ecs-agent

[Install]
WantedBy=multi-user.target