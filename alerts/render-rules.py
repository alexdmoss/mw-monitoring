#!/usr/bin/env python

import os
import sys
import yaml


def get_alerts_from_rule_spec(rule_spec):
    alerts = []
    for group in rule_spec['groups']:
        for rule in group['rules']:
            if 'alert' in rule:
                alerts.append(rule)
    return alerts


def validate(alert):
    errors = []
    validate_group_label(alert, errors)
    validate_receiver_label(alert, errors)
    validate_severity_label(alert, errors)
    validate_summary_annotation(alert, errors)
    validate_dashboard_annotation(alert, errors)
    return [error for error in errors if error]


def validate_group_label(alert, errors):
    if 'group' not in alert['labels'] or len(alert['labels']['group']) == 0:
        errors.append('labels.group missing or empty')


def validate_receiver_label(alert, errors):
    if 'receiver' not in alert['labels'] or len(alert['labels']['receiver']) == 0:
        errors.append('labels.receiver missing or empty')


def validate_severity_label(alert, errors):
    if 'severity' not in alert['labels'] or len(alert['labels']['severity']) == 0:
        errors.append('labels.severity missing or empty')


def validate_summary_annotation(alert, errors):
    if 'summary' not in alert['annotations'] or len(alert['annotations']['summary']) == 0:
        errors.append('annotations.summary missing or empty')


def validate_dashboard_annotation(alert, errors):
    if 'dashboard' not in alert['annotations']:
        errors.append('annotations.dashboard missing')
        return
    dashboard = alert['annotations']['dashboard']
    if not dashboard.startswith('/d/'):
        errors.append(
            f'annotations.dashboard should start with \'/d/\': {dashboard}')


def validate_rules(directory):
    validation_errors = 0

    print('-> [INFO] Validating alert rules ...')

    for filename in os.listdir(directory):
        with open(f'{directory}/{filename}', 'r') as file_content:
            rule_spec = yaml.load(file_content, Loader=yaml.SafeLoader)

        alerts = get_alerts_from_rule_spec(rule_spec)
        for alert in alerts:
            errors = validate(alert)
            if len(errors) != 0:
                validation_errors += 1
                for error in errors:
                    print(
                        f'-> [ERROR] [{directory}/{filename}/{alert["alert"]}] {error}')

    return validation_errors


def render(directory):

    print('-> [INFO] Generating rules yaml ...')

    for filename in os.listdir(directory):
        with open(f'{directory}/{filename}', 'r') as file_content:
            rule_spec = yaml.load(file_content, Loader=yaml.SafeLoader)
            stripped_filename = filename.replace('.yaml', '')

            rule_yaml = {
                'apiVersion': 'monitoring.coreos.com/v1',
                'kind': 'PrometheusRule',
                'metadata': {
                    'name': f'{stripped_filename}',
                    'namespace': 'metrics',
                    'labels': {
                        'source': 'mw-monitoring-alerts',
                    },
                },
                'spec': rule_spec
            }

            with open('/tmp/alert-rules.yaml', 'a') as yaml_file:
                yaml_file.write('---\n' + yaml.dump(rule_yaml))


if __name__ == "__main__":
    validation_errors = 0
    validation_errors += validate_rules('rules')

    if validation_errors > 0:
        sys.exit(1)

    render('rules')
    render('coreos-rules')

    print('-> [INFO] Script complete.')

    sys.exit(0)
