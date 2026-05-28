#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "gcloud installed" command -v gcloud
check "gsutil installed" command -v gsutil
check "bq installed" command -v bq
check "gcloud version runs" gcloud --version

reportResults
