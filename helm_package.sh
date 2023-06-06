#!/usr/bin/env bash
CN=.
helm lint $CN
helm package $CN
Helm repo index  .