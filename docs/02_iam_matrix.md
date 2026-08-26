# IAM- und Least-Privilege-Lab

Dieses Lab trennt Verantwortlichkeiten in drei **Testgruppen**. Die Gruppen werden im Microsoft-Entra-Portal angelegt; ihre Object IDs werden nur als Terraform-Variablen übergeben. Es werden weder Personen noch Produktionsgruppen automatisiert erstellt.

| Testgruppe | Persona | Azure-Rolle und Scope | Erlaubt | Absichtlich nicht erlaubt |
|---|---|---|---|---|
| `cs-lab-developers` | Entwickler | `Contributor` auf `rg-cloudsecurity-lab` | Lab-Ressourcen erstellen und konfigurieren | Azure-Rollenzuweisungen verwalten, Zugriff auf Key-Vault-Secrets erhalten |
| `cs-lab-readers` | Auditor/Leser | `Reader` auf `rg-cloudsecurity-lab` | Konfiguration und Ressourcenbestand ansehen | Änderungen, Secret-Zugriff, Berechtigungsänderungen |
| `cs-lab-security-operators` | Security Operator | `Reader` auf Resource Group; `Key Vault Administrator` ausschließlich auf dem Key Vault | Sicherheitskonfiguration prüfen und Key-Vault-Objekte im Lab verwalten | Änderungen an Storage/Monitoring, Subscription-weite Adminrechte |
| Workload-Identity (optional) | Anwendung | `Key Vault Secrets User` ausschließlich auf dem Key Vault | Nur die benötigten Secrets lesen | Vault-Verwaltung, Secret-Änderung, Zugriff auf andere Ressourcen |

Die Rolle **Owner** wird bewusst keiner Testgruppe gegeben. Microsoft empfiehlt, nur den Zugriff zu vergeben, der zur Aufgabenerfüllung erforderlich ist, und breitere Rollen an breiteren Scopes zu vermeiden.[1] Die Zuweisung erfolgt auf Gruppen statt auf einzelne Benutzer. Das ist wartbarer und erlaubt eine saubere Zuordnung von Verantwortlichkeiten.[1]

## Durchführung des Labs

1. Lege im Microsoft-Entra-Admincenter drei **ausschließlich für das Lab bestimmte** Sicherheitsgruppen mit den Namen aus der Matrix an.
2. Ermittle die jeweilige Object ID der Gruppen. Trage nur diese IDs in eine lokale Datei `terraform/terraform.tfvars` ein; sie ist durch `.gitignore` vom Commit ausgeschlossen.
3. Prüfe die Anmeldung mit einem Testkonto je Gruppe. Dokumentiere das erwartete und tatsächliche Ergebnis in der untenstehenden Nachweistabelle.
4. Entferne nach dem Lab nicht mehr benötigte Gruppenmitgliedschaften und führe `terraform destroy` aus, sofern die Ressourcen nicht weiter als Portfolio-Screenshot dienen sollen.

## Testfälle für den Nachweis

| Testfall | Testkonto | Erwartung | Nachweis für das Portfolio |
|---|---|---|---|
| Ressourcenübersicht öffnen | Leser | Erfolgreich, nur Leserechte | Screenshot des Portals mit `Reader`-Assignment |
| Storage-Konfiguration ändern | Leser | Zugriff verweigert | Screenshot/Log der Fehlermeldung, ohne personenbezogene Daten |
| Storage-Konfiguration ändern | Entwickler | Erfolgreich | Vorher-/Nachher-Screenshot und zugehöriger Terraform-Commit |
| Secret auflisten | Entwickler | Zugriff verweigert | Audit-Event im Key-Vault-Log oder Fehleranzeige |
| Testsecret im Key Vault verwalten | Security Operator | Erfolgreich, aber nur im Vault-Scope | Screenshot der engen Zuweisung auf Key-Vault-Scope |
| Rolle zuweisen | Entwickler | Zugriff verweigert | Portal-/CLI-Fehler und kurze Erklärung der Schutzwirkung |

> **MFA und Conditional Access:** Konfiguriere MFA für die Testkonten nach den Regeln deines Tenants. Diese Richtlinien liegen außerhalb des Terraform-Scope dieses Repositories, weil sie Tenant-Administrative Rechte und in vielen Szenarien passende Entra-Lizenzierung erfordern. Für ein Bewerbungsportfolio ist es wichtig, dies transparent zu benennen, statt eine nicht nachweisbare Kontrolle zu behaupten.

## Portfolio-Erklärung in einem Satz

> „Ich habe Zugriffe über Entra-Gruppen und Azure RBAC auf Resource-Group- und Ressourcenscope beschränkt, direkte Benutzerzuweisungen vermieden und negative Berechtigungstests dokumentiert.“

## Referenzen

[1] [Microsoft Learn: Best practices for Azure RBAC](https://learn.microsoft.com/en-us/azure/role-based-access-control/best-practices)
