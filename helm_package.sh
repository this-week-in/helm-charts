#!/usr/bin/env bash
CN=twi-system-chart
helm lint $CN
helm package $CN
Helm repo index  .