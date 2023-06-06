#!/usr/bin/env bash
CN=twi
helm lint $CN
helm package $CN
Helm repo index  .