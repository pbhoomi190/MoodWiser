# MoodWiser

MoodWiser is a Flutter app for recording mood check-ins.

## Track your mood

- Rate how you feel and optionally select feelings and triggers.
- Feeling and trigger chips show up to two rows initially. Select **More...** to see the remaining options, or **Show less** to collapse the list.
- Add an optional note and choose the date and time for the check-in.

## Push email notifications

The GitHub Actions workflow emails the pushed commit message to a recipient
configured privately as a repository actions secret under
**Settings → Secrets and variables → Actions**:

- `SMTP_HOST`
- `SMTP_PORT` (`465` for SSL or another port that supports STARTTLS, typically `587`)
- `SMTP_USERNAME`
- `SMTP_PASSWORD`
- `SMTP_FROM` (the authenticated email address or an address authorized by the provider)
- `SMTP_TO` (the private recipient email address)
