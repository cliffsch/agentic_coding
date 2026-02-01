# Python/SSH NFRs

> Platform-specific non-functional requirements for Python projects with SSH deployment.
> These extend the common NFRs in `COMMON.md`.

## Platform Context

Python scripts and services deployed via SSH typically run on remote Linux servers, often as long-running processes or scheduled jobs. Proper signal handling, logging, and graceful shutdown are critical for operational reliability.

---

## Python Operability (PY-OPS)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| PY-OPS-1 | Human-readable logging | Standard `logging` module; JSON optional | Required |
| PY-OPS-2 | Signal handling | Handle SIGTERM/SIGINT for graceful shutdown | Required |
| PY-OPS-3 | Debug toggle | `LOG_LEVEL` env var, default INFO | Required |
| PY-OPS-4 | Health check capability | Status file, HTTP endpoint, or socket | Recommended |

### PY-OPS Implementation Patterns

**PY-OPS-1 Logging Setup:**
```python
import logging
import os
import sys
from datetime import datetime

def setup_logging(name: str) -> logging.Logger:
    """Configure logging with level from environment."""
    log_level = os.getenv('LOG_LEVEL', 'INFO').upper()

    # Create logger
    logger = logging.getLogger(name)
    logger.setLevel(getattr(logging, log_level, logging.INFO))

    # Console handler with human-readable format
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(logging.Formatter(
        '%(asctime)s [%(levelname)s] %(name)s: %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    ))
    logger.addHandler(handler)

    # Optional: File handler with rotation
    if os.getenv('LOG_FILE'):
        from logging.handlers import RotatingFileHandler
        file_handler = RotatingFileHandler(
            os.getenv('LOG_FILE'),
            maxBytes=10_000_000,  # 10MB
            backupCount=5
        )
        file_handler.setFormatter(handler.formatter)
        logger.addHandler(file_handler)

    return logger

# Usage
log = setup_logging('myapp')
log.info('Application started')
log.debug('Debug info: %s', details)  # Only shown when LOG_LEVEL=DEBUG
```

**PY-OPS-2 Signal Handling:**
```python
import signal
import sys
from typing import Callable

class GracefulShutdown:
    """Handle shutdown signals gracefully."""

    def __init__(self):
        self.shutdown_requested = False
        self._cleanup_callbacks: list[Callable] = []

        signal.signal(signal.SIGTERM, self._handle_signal)
        signal.signal(signal.SIGINT, self._handle_signal)

    def _handle_signal(self, signum, frame):
        log.info(f'Received signal {signum}, initiating shutdown...')
        self.shutdown_requested = True
        self._run_cleanup()

    def register_cleanup(self, callback: Callable):
        """Register a cleanup function to run on shutdown."""
        self._cleanup_callbacks.append(callback)

    def _run_cleanup(self):
        for callback in self._cleanup_callbacks:
            try:
                callback()
            except Exception as e:
                log.error(f'Cleanup error: {e}')
        sys.exit(0)

# Usage
shutdown = GracefulShutdown()
shutdown.register_cleanup(lambda: db.close())
shutdown.register_cleanup(lambda: log.info('Shutdown complete'))

while not shutdown.shutdown_requested:
    do_work()
```

**PY-OPS-4 Health Check File:**
```python
import os
from datetime import datetime
from pathlib import Path

HEALTH_FILE = Path(os.getenv('HEALTH_FILE', '/tmp/app.health'))

def update_health():
    """Update health check file with current timestamp."""
    HEALTH_FILE.write_text(datetime.utcnow().isoformat())

def check_health(max_age_seconds: int = 60) -> bool:
    """Check if health file exists and is recent."""
    if not HEALTH_FILE.exists():
        return False

    mtime = datetime.fromtimestamp(HEALTH_FILE.stat().st_mtime)
    age = (datetime.now() - mtime).total_seconds()
    return age < max_age_seconds
```

---

## Python Performance (PY-PRF)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| PY-PRF-1 | Graceful shutdown | Context managers, atexit handlers | Required |
| PY-PRF-2 | Connection pooling | Reuse database/HTTP connections | Recommended |
| PY-PRF-3 | Memory-conscious data handling | Generators for large datasets | Recommended |

### PY-PRF Implementation Patterns

**PY-PRF-1 Context Manager Pattern:**
```python
from contextlib import contextmanager
import atexit

class DatabaseConnection:
    def __enter__(self):
        self.conn = create_connection()
        return self.conn

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.conn.close()
        log.info('Database connection closed')

# atexit for cleanup when context managers aren't suitable
def cleanup():
    log.info('Running atexit cleanup')
    # Close connections, flush buffers, etc.

atexit.register(cleanup)
```

**PY-PRF-3 Generator Pattern:**
```python
def process_large_file(filepath: str):
    """Process file line by line without loading into memory."""
    with open(filepath) as f:
        for line in f:
            yield process_line(line)

# Usage - memory efficient
for result in process_large_file('/path/to/large.csv'):
    handle_result(result)
```

---

## Python Alerting (PY-ALT)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| PY-ALT-1 | Operator notifications | Telegram, email, or webhook | Required |
| PY-ALT-2 | Alert throttling | Rate limit repeated alerts | Required |
| PY-ALT-3 | Startup/shutdown notifications | Notify on process lifecycle events | Recommended |

### PY-ALT Implementation Patterns

**PY-ALT-1 Telegram Alert:**
```python
import os
import requests
from functools import lru_cache

@lru_cache(maxsize=1)
def get_telegram_config():
    return {
        'token': os.environ['TELEGRAM_BOT_TOKEN'],
        'chat_id': os.environ['TELEGRAM_CHAT_ID'],
    }

def send_telegram_alert(message: str, level: str = 'INFO'):
    """Send alert to Telegram."""
    config = get_telegram_config()
    emoji = {'INFO': 'ℹ️', 'WARN': '⚠️', 'ERROR': '❌', 'CRITICAL': '🔥'}.get(level, '')

    try:
        response = requests.post(
            f"https://api.telegram.org/bot{config['token']}/sendMessage",
            json={
                'chat_id': config['chat_id'],
                'text': f"{emoji} [{level}] {message}",
                'parse_mode': 'HTML',
            },
            timeout=10,
        )
        response.raise_for_status()
    except Exception as e:
        log.error(f'Failed to send Telegram alert: {e}')

# Email alternative
import smtplib
from email.message import EmailMessage

def send_email_alert(subject: str, body: str):
    """Send alert via email."""
    msg = EmailMessage()
    msg['Subject'] = f'[Alert] {subject}'
    msg['From'] = os.environ['SMTP_FROM']
    msg['To'] = os.environ['ALERT_EMAIL']
    msg.set_content(body)

    with smtplib.SMTP(os.environ['SMTP_HOST'], int(os.environ.get('SMTP_PORT', 587))) as smtp:
        smtp.starttls()
        smtp.login(os.environ['SMTP_USER'], os.environ['SMTP_PASS'])
        smtp.send_message(msg)
```

**PY-ALT-2 Alert Throttling:**
```python
from datetime import datetime, timedelta
from collections import defaultdict

class AlertThrottler:
    """Prevent alert spam by throttling repeated alerts."""

    def __init__(self, cooldown_seconds: int = 300):
        self.cooldown = timedelta(seconds=cooldown_seconds)
        self.last_sent: dict[str, datetime] = defaultdict(lambda: datetime.min)

    def should_send(self, alert_key: str) -> bool:
        """Check if enough time has passed to send this alert again."""
        now = datetime.now()
        if now - self.last_sent[alert_key] >= self.cooldown:
            self.last_sent[alert_key] = now
            return True
        return False

# Usage
throttler = AlertThrottler(cooldown_seconds=300)

def alert_on_error(error: Exception, context: str):
    alert_key = f"{type(error).__name__}:{context}"
    if throttler.should_send(alert_key):
        send_telegram_alert(f"{context}: {error}", level='ERROR')
```

---

## Python Security (PY-SEC)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| PY-SEC-1 | Secrets from environment | `os.environ` or secrets manager | Required |
| PY-SEC-2 | SSH key security | Use SSH agent or encrypted keys | Required |
| PY-SEC-3 | Input validation | Validate CLI args and config files | Required |

### PY-SEC Implementation Patterns

**PY-SEC-1 Environment Variables:**
```python
import os

def get_required_env(key: str) -> str:
    """Get required environment variable or raise."""
    value = os.environ.get(key)
    if not value:
        raise EnvironmentError(f'Required environment variable {key} is not set')
    return value

# Usage
DATABASE_URL = get_required_env('DATABASE_URL')
API_KEY = get_required_env('API_KEY')
```

**PY-SEC-3 CLI Argument Validation:**
```python
import argparse
from pathlib import Path

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--config', type=Path, required=True)
    parser.add_argument('--limit', type=int, default=100)
    args = parser.parse_args()

    # Validate
    if not args.config.exists():
        parser.error(f'Config file not found: {args.config}')
    if args.limit < 1 or args.limit > 10000:
        parser.error(f'Limit must be between 1 and 10000')

    return args
```

---

## SSH Deployment (PY-SSH)

| ID | Requirement | Implementation Pattern | Default |
|----|-------------|------------------------|---------|
| PY-SSH-1 | Deployment documentation | README with deploy commands | Required |
| PY-SSH-2 | Service management | systemd unit file or supervisor config | Recommended |
| PY-SSH-3 | Log persistence | Log to file with rotation | Required |

### PY-SSH Implementation Patterns

**PY-SSH-2 Systemd Service:**
```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Python Application
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/myapp
Environment=LOG_LEVEL=INFO
Environment=LOG_FILE=/var/log/myapp/app.log
ExecStart=/opt/myapp/venv/bin/python -m myapp
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

---

## Compliance Checklist for Design Review

- [ ] Logging configured with level from environment
- [ ] SIGTERM/SIGINT handlers implemented
- [ ] Graceful shutdown cleans up all resources
- [ ] Alert mechanism configured (Telegram/email/webhook)
- [ ] Alert throttling prevents spam
- [ ] All secrets from environment variables
- [ ] Input validation for CLI args and config
- [ ] Context managers used for resource management
- [ ] Deployment documentation complete
- [ ] Log rotation configured
