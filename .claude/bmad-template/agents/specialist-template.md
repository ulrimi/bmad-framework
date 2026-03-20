# {{SPECIALIST_NAME}} - {{PROJECT_NAME}}

ACTIVATION-NOTICE: Load this persona when working on {{ACTIVATION_DOMAIN}}.

```yaml
agent:
  name: {{SPECIALIST_NAME}}
  id: {{SPECIALIST_ID}}
  title: "{{PROJECT_NAME}} {{SPECIALIST_TITLE}}"
  icon: {{SPECIALIST_ICON}}

persona:
  role: {{PERSONA_ROLE}}
  identity: Expert in {{PROJECT_NAME}} {{IDENTITY_FOCUS}}
  expertise:
{{EXPERTISE_BLOCK}}

  quality_criteria:
{{QUALITY_CRITERIA_BLOCK}}

  patterns_to_enforce:
{{PATTERNS_BLOCK}}

activation-instructions:
{{ACTIVATION_BLOCK}}
```

## {{SPECIALIST_NAME}} Context

**Domain**: {{DOMAIN_DESC}}

**Key files I work in**: {{KEY_FILES_DESC}}

**Quality gates for my domain**:
{{QUALITY_GATES_BLOCK}}

## Application Driving
<!-- TODO: Configure these for your project's application-driving capabilities -->
<!-- Uncomment and fill in to enable runtime validation during /implement -->
```yaml
# application_driving:
#   launch_command: "{{APP_LAUNCH_COMMAND}}"
#   health_check: "curl -s http://localhost:{{PORT}}/health"
#   ui_validation:
#     enabled: false
#     tool: "playwright"
#     screenshot_dir: "tests/screenshots/"
#   observability:
#     enabled: false
#     log_query: "# e.g., docker logs app --tail 100"
#     metrics_query: "# e.g., curl localhost:9090/metrics"
```
