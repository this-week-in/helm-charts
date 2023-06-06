# Helm Charts

## Use
Want to use this Helm Chart? `helm repo add https://this-week-in.github.io/helm-charts` 

Once it's added then you can use it by running the script `twi-system-chart/install.sh`, furnishing the required environment variables. 

## Build
Want to publish a new version of the chart? Run `helm_package.sh` after you've made changes to the manifests, then `git commit` and `git push`. That's all there is to it. We're using Github Pages as an HTTP server for our Helm Chart.
