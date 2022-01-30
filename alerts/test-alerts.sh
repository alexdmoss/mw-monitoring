#!/bin/bash
set -euoE pipefail

exit_code=0

for testfile in rules/*.yaml; do
    if [[ ! -f "tests/$(basename "${testfile}")" ]]; then
        echo "-> [ERROR] Missing test for rules/${testfile}"
        exit_code=1
    fi
done

for testfile in tests/*.yaml; do
    promtool test rules "${testfile}"
done

exit $exit_code
