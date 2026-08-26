# Secure Azure Workload Lab

**Cloud-Security-Portfolio-Projekt** für Bewerbungen in Cloud Security, Cloud Operations, Systemadministration und SOC L1.

Dieses Azure-Testlab demonstriert sichere Infrastruktur mit **Terraform**, **Least-Privilege-RBAC**, **Key Vault**, **Monitoring**, **KQL-Detections** und **Incident Response**. Es enthält ausschließlich simulierte Daten und keine produktiven Zugangsdaten oder Ressourcen.

## Kompetenznachweise

| Bereich | Umsetzung |
|---|---|
| Infrastructure as Code | Azure Resource Group, Storage Account, Key Vault und Log Analytics per Terraform |
| IAM / Entra ID | Gruppenbasierte RBAC-Zuweisungen mit engen Scopes und Negativtests |
| Cloud Hardening | HTTPS-only, TLS 1.2+, deaktivierter Public Blob Access und Shared-Key-Zugriff |
| Secret Management | Azure RBAC, Soft Delete und Purge Protection für Key Vault |
| Monitoring & Detection | Diagnostic Settings, Log Analytics, KQL und Python-Analyzer für Sign-in-Events |
| Incident Response | Triage-, Containment-, Recovery- und Lessons-Learned-Runbook |
| Sichere Automatisierung | CI-Prüfung für Terraform-Format, Terraform-Validierung und Python-Tests |

## Lokale Verifikation ohne Azure-Kosten

```bash
make test
make analyze
cat artifacts/simulated_signin_report.json
```

Das erwartete Ergebnis ist **ein Alert** für fünf simulierte fehlgeschlagene Anmeldungen innerhalb von 15 Minuten.

> **Ehrliche Einordnung:** Dieses Repository ist ein Lern- und Demonstrationslab, keine produktive Azure Landing Zone. Für reale Umgebungen müssen Tenant-Vorgaben, Netzwerkarchitektur, MFA beziehungsweise Conditional Access, Kosten und Sicherheitskontrollen separat geplant und getestet werden.

## Inhalt

Terraform-Konfiguration, IAM-Matrix, KQL-Detections, Incident-Response-Runbook, simulierte Logs, Python-Tests, CI-Pipeline und ein editierbares Architekturdiagramm.

## Bewerbungstext

> **Secure Azure Workload Lab:** Aufbau und Dokumentation einer gehärteten Azure-Testumgebung mit Terraform. Umsetzung von Least-Privilege-RBAC, Key-Vault-Härtung, Audit-Logging, KQL-Detections und einem Incident-Response-Runbook.

## Referenzen

- [Microsoft Learn: Secure your Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/secure-key-vault)
- [Microsoft Learn: Best practices for Azure RBAC](https://learn.microsoft.com/en-us/azure/role-based-access-control/best-practices)
- [Microsoft Learn: Diagnostic settings in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/platform/diagnostic-settings)
