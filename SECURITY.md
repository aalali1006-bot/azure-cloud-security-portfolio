# Sicherheitsrichtlinie

## Unterstützter Scope

Dieses Repository ist ein **Ausbildungs- und Portfolio-Lab**. Es enthält keine öffentliche Produktion, keine echten Secrets und keinen betriebenen Service. Sicherheitsmeldungen betreffen daher vor allem die veröffentlichten Terraform-Beispiele, Skripte, Workflows oder versehentlich eingecheckte Daten.

## Sicherheitsproblem melden

Bitte veröffentliche keine potenziellen Zugangsdaten oder ausführlichen Exploit-Schritte in einem öffentlichen Issue. Wenn dieses Repository unter einem persönlichen GitHub-Konto veröffentlicht wird, soll die Kontaktmöglichkeit im GitHub-Profil oder eine private Security-Advisory-Funktion genutzt werden.

Eine hilfreiche Meldung enthält eine kurze Beschreibung, betroffene Datei und Zeile, nachvollziehbare Reproduktionsschritte ohne Schadcode sowie eine Einschätzung der möglichen Auswirkung. Nach der Prüfung wird das Problem behoben, dokumentiert und als Commit nachvollziehbar gemacht.

## Umgang mit Geheimnissen

Echte Tokens, Client Secrets, Passwörter, private Schlüssel, Terraform States, `terraform.tfvars` mit Organisationsdaten und Screenshots mit sensitiven Kennungen gehören **nicht** in dieses Repository. Die `.gitignore`-Regeln sind eine Hilfestellung, ersetzen aber keine Prüfung vor jedem Commit.
