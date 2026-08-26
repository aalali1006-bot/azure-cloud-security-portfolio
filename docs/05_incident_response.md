# Incident-Response-Runbook: Auffälliger Secret-Zugriff

Dieses Runbook zeigt, wie ich einen Alarm wegen wiederholt verweigerter Key-Vault-Operationen bearbeite. Es ist auf das Portfolio-Lab beschränkt und ersetzt keinen organisationsweiten Incident-Response-Prozess.

> **Auslöser:** Die Alert-Regel `alert-keyvault-denied-operations` meldet mindestens drei fehlgeschlagene Lese- oder Listenoperationen innerhalb einer Stunde.

| Phase | Ziel | Konkrete Tätigkeit | Nachweis |
|---|---|---|---|
| Erkennen | Alarm verifizieren | Uhrzeit, Ressource, Caller-IP und Anzahl der Fehler im Alert prüfen | Alert-Screenshot oder exportierter Log-Ausschnitt |
| Triage | Fehlkonfiguration von möglichem Missbrauch trennen | Query 1 und 2 aus `04_detection_queries.kql` ausführen; betroffene Identität, IP und Operation feststellen | Ticket-/Fallnotiz mit Zeitachse |
| Eindämmen | Weitere schädliche Zugriffe stoppen | Betroffene Testgruppenmitgliedschaft entfernen oder Workload-Identity deaktivieren; **keine** produktiven Secrets in diesem Lab verwenden | Änderung im Entra-/Azure-Audit-Log |
| Untersuchung | Umfang bestimmen | Azure Activity, Key Vault Audit Events und ggf. Sign-in Logs für den Zeitraum prüfen | Gesicherte Query-Ergebnisse |
| Wiederherstellung | Sicheren Betriebszustand herstellen | Fehlkonfiguration korrigieren, Berechtigung auf erforderlichen Minimal-Scope zurücksetzen; bei Verdacht auf Secret-Offenlegung ein neues Testsecret erzeugen | Terraform-Commit und erneuter Negativtest |
| Nachbereitung | Wiederholung reduzieren | Ursache, Auswirkungen, Entscheidung und Follow-up festhalten; Detection-Schwellenwert oder IAM-Matrix anpassen | Kurzer Lessons-Learned-Eintrag |

## Triage-Ablauf

1. **Alarm nicht vorschnell als Angriff werten.** Zuerst wird geprüft, ob ein Testkonto kurz vor dem Ereignis bewusst eine negative Berechtigungsprüfung durchgeführt hat.
2. Der Ereigniszeitraum wird um mindestens 30 Minuten vor und nach dem ersten Fehler erweitert. Dadurch lassen sich vorangehende Rollenänderungen, IP-Wechsel oder administrative Konfigurationsänderungen erkennen.
3. Die Analyse grenzt auf die konkrete Ressource, IP-Adresse und Identität ein. Nur die Daten, die zur Klärung erforderlich sind, werden exportiert; Log-Auszüge für das Portfolio werden anonymisiert.
4. Bei einer tatsächlich unberechtigten Testidentität wird zuerst **deren Zugang** eingeschränkt, nicht pauschal die gesamte Umgebung abgeschaltet. Das erhält die Nachvollziehbarkeit und reduziert den Einfluss auf andere Lab-Arbeiten.
5. Nach der Korrektur wird derselbe Negativtest wiederholt. Erst wenn der Zugriff zuverlässig verweigert wird und das Ereignis im Log sichtbar ist, gilt die Maßnahme im Portfolio als verifiziert.

## Beispiel-Fallnotiz

| Feld | Beispielwert |
|---|---|
| Fall-ID | `LAB-IR-001` |
| Erkennung | `2026-08-26 10:15 UTC` – Alert: 4 verweigerte `SecretGet`-Operationen |
| Betroffene Ressource | `kv-cloudsecurity-lab-abc123` |
| Erste Hypothese | Entwickler-Testkonto versuchte ein nicht zugewiesenes Secret zu lesen |
| Evidenz | Key-Vault-Audit-Logs, Azure Activity und Terraform-State/Plan |
| Eindämmung | Keine erforderlich, da Negativtest bestätigt und kein Zugriff erfolgreich war |
| Ergebnis | IAM-Design bestätigt; Query und Screenshot als Portfolio-Evidenz abgelegt |
| Follow-up | Prüfen, ob der Alert-Kontext einen Link zur KQL-Query enthalten soll |

## Was ich im Bewerbungsgespräch dazu erklären würde

> „Ich behandle einen Alert als Signal, nicht als Beweis. Ich prüfe zuerst Identität, Zeitfenster, Ressource und vorherige Änderungen. Dann grenze ich ein, dämme minimalinvasiv ein, dokumentiere die Entscheidung und teste die Kontrolle erneut. So verbinde ich Monitoring mit einem nachvollziehbaren Betriebsprozess.“

## Sicherheits- und Datenschutzregel

Veröffentliche weder vollständige UPNs, IP-Adressen, Token, Subscription IDs noch Screenshots mit Geheimnissen. Anonymisiere Portfolio-Evidenz und verwende ausschließlich Testkonten und Testdaten.
