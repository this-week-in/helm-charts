#!/usr/bin/env bash
CN=twi
helm lint $CN
helm package $CN
helm repo index --url https://this-week-in.github.io/helm-charts/ .