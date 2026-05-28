#!/bin/bash
set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "java installed" command -v java
check "jmeter installed" command -v jmeter
check "JMETER_HOME exists" test -d /opt/jmeter

reportResults
