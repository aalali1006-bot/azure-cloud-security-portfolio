#!/usr/bin/env python3
"""Erkennt Brute-Force-ähnliche Muster in simulierten Entra-Sign-in-Logs.

Das Skript verarbeitet ausschließlich JSON Lines mit Testdaten. Es stellt keine
Verbindung zu Azure her und enthält keine Zugangsdaten.
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any


REQUIRED_FIELDS = {"timestamp", "user_principal_name", "ip_address", "status"}
FAILED_STATUSES = {"failure", "failed", "denied"}


def parse_timestamp(value: str) -> datetime:
    """Parse an ISO-8601 timestamp and normalize it to UTC."""
    parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    if parsed.tzinfo is None:
        raise ValueError("timestamp muss eine Zeitzone enthalten, z. B. Z")
    return parsed.astimezone(timezone.utc)


def load_events(path: Path) -> list[dict[str, Any]]:
    """Load and validate JSONL events, skipping blank lines."""
    events: list[dict[str, Any]] = []
    for line_number, raw_line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        if not raw_line.strip():
            continue
        try:
            event = json.loads(raw_line)
        except json.JSONDecodeError as exc:
            raise ValueError(f"Ungültiges JSON in Zeile {line_number}: {exc.msg}") from exc
        missing = REQUIRED_FIELDS.difference(event)
        if missing:
            raise ValueError(f"Fehlende Felder in Zeile {line_number}: {', '.join(sorted(missing))}")
        event["parsed_timestamp"] = parse_timestamp(event["timestamp"])
        events.append(event)
    return sorted(events, key=lambda item: item["parsed_timestamp"])


def detect_failed_signins(
    events: list[dict[str, Any]], threshold: int, window_minutes: int
) -> list[dict[str, Any]]:
    """Create one alert per user/IP if failures meet threshold inside the window."""
    failed_by_identity: dict[tuple[str, str], list[dict[str, Any]]] = defaultdict(list)
    for event in events:
        if str(event["status"]).lower() in FAILED_STATUSES:
            key = (event["user_principal_name"], event["ip_address"])
            failed_by_identity[key].append(event)

    alerts: list[dict[str, Any]] = []
    window = timedelta(minutes=window_minutes)
    for (user, ip_address), failures in failed_by_identity.items():
        left = 0
        emitted_windows: set[tuple[str, str]] = set()
        for right, current in enumerate(failures):
            while current["parsed_timestamp"] - failures[left]["parsed_timestamp"] > window:
                left += 1
            current_window = failures[left : right + 1]
            if len(current_window) >= threshold:
                window_key = (
                    current_window[0]["parsed_timestamp"].isoformat(),
                    current_window[-1]["parsed_timestamp"].isoformat(),
                )
                if window_key in emitted_windows:
                    continue
                emitted_windows.add(window_key)
                alerts.append(
                    {
                        "alert_type": "repeated_failed_signins",
                        "severity": "medium",
                        "user_principal_name": user,
                        "ip_address": ip_address,
                        "failed_signin_count": len(current_window),
                        "window_start_utc": current_window[0]["parsed_timestamp"].isoformat(),
                        "window_end_utc": current_window[-1]["parsed_timestamp"].isoformat(),
                        "recommended_action": (
                            "Triage: Testfall verifizieren, Sign-in- und Audit-Logs prüfen, "
                            "bei unberechtigter Aktivität Identität gezielt einschränken."
                        ),
                    }
                )
                break
    return sorted(alerts, key=lambda item: item["window_end_utc"])


def build_report(alerts: list[dict[str, Any]], event_count: int, threshold: int, window_minutes: int) -> dict[str, Any]:
    """Create a portable JSON report."""
    return {
        "report_name": "simulated_entra_signin_analysis",
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "event_count": event_count,
        "detection_rule": {
            "name": "repeated_failed_signins",
            "threshold": threshold,
            "window_minutes": window_minutes,
            "grouping": "user_principal_name + ip_address",
        },
        "alert_count": len(alerts),
        "alerts": alerts,
        "data_notice": "Ausschließlich simulierte Testdaten; keine Azure-Verbindung.",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Analysiert simulierte Sign-in-Logs im JSONL-Format.")
    parser.add_argument("--input", type=Path, required=True, help="Pfad zur JSONL-Eingabedatei")
    parser.add_argument("--output", type=Path, required=True, help="Pfad für den JSON-Report")
    parser.add_argument("--threshold", type=int, default=5, help="Anzahl der Fehler für einen Alert (Standard: 5)")
    parser.add_argument("--window-minutes", type=int, default=15, help="Zeitfenster in Minuten (Standard: 15)")
    args = parser.parse_args()

    if args.threshold < 2 or args.window_minutes < 1:
        parser.error("threshold muss mindestens 2 und window-minutes mindestens 1 sein.")
    if not args.input.is_file():
        parser.error(f"Eingabedatei fehlt: {args.input}")

    try:
        events = load_events(args.input)
        alerts = detect_failed_signins(events, args.threshold, args.window_minutes)
    except ValueError as exc:
        print(f"Fehler: {exc}", file=sys.stderr)
        return 2

    report = build_report(alerts, len(events), args.threshold, args.window_minutes)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"{len(events)} Ereignisse analysiert; {len(alerts)} Alert(s) geschrieben nach {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
