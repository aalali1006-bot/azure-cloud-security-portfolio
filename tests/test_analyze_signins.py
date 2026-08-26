import sys
import unittest
from datetime import datetime, timezone
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT / "scripts"))

from analyze_signins import detect_failed_signins  # noqa: E402


def event(timestamp: str, user: str, ip: str, status: str) -> dict:
    return {
        "timestamp": timestamp,
        "parsed_timestamp": datetime.fromisoformat(timestamp.replace("Z", "+00:00")).astimezone(timezone.utc),
        "user_principal_name": user,
        "ip_address": ip,
        "status": status,
    }


class DetectFailedSigninsTests(unittest.TestCase):
    def test_creates_alert_for_five_failures_inside_window(self):
        events = [
            event(f"2026-08-26T09:{minute:02d}:00Z", "developer@example.invalid", "203.0.113.77", "failure")
            for minute in (0, 2, 4, 6, 8)
        ]
        alerts = detect_failed_signins(events, threshold=5, window_minutes=15)

        self.assertEqual(len(alerts), 1)
        self.assertEqual(alerts[0]["failed_signin_count"], 5)
        self.assertEqual(alerts[0]["user_principal_name"], "developer@example.invalid")

    def test_ignores_four_failures_below_threshold(self):
        events = [
            event(f"2026-08-26T09:{minute:02d}:00Z", "reader@example.invalid", "198.51.100.10", "denied")
            for minute in (0, 2, 4, 6)
        ]
        alerts = detect_failed_signins(events, threshold=5, window_minutes=15)

        self.assertEqual(alerts, [])

    def test_ignores_events_outside_time_window(self):
        events = [
            event(f"2026-08-26T09:{minute:02d}:00Z", "reader@example.invalid", "198.51.100.10", "failure")
            for minute in (0, 10, 20, 30, 40)
        ]
        alerts = detect_failed_signins(events, threshold=5, window_minutes=15)

        self.assertEqual(alerts, [])


if __name__ == "__main__":
    unittest.main()
