#!/bin/bash

# Set default values
name="testalert"
url='http://localhost:9093/api/v2/alerts'
summary='Testing summary!'
group='mw-monitoring'
severity='none'
receiver='default'

# Function to send alert
send_alert() {
    local status=$1
    curl -XPOST $url -H "Content-Type: application/json" -d "[
        {
            \"status\": \"$status\",
            \"labels\": {
                \"alertname\": \"$name\",
                \"severity\":\"$severity\",
                \"group\": \"$group\",
                \"receiver\": \"$receiver\"
            },
            \"annotations\": {
                \"summary\": \"$summary\"
            },
            \"generatorURL\": \"https://prometheus.local/<generating_expression>\"
        }
    ]"
    echo ""
}

# Main script
echo "Firing up alert $name"
send_alert "firing" "$1"

read -p "Press enter to resolve alert"

echo "Sending resolve"
send_alert "resolved" "$1"
