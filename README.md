# MoodWiser

MoodWiser is a Flutter app for recording mood check-ins.

## Track your mood

- Rate how you feel and optionally select feelings and triggers.
- Feeling and trigger chips show up to two rows initially. Select **More...** to see the remaining options, or **Show less** to collapse the list.
- Add an optional note and choose the date and time for the check-in.

## Mood analysis

- Weekly, monthly, and yearly insights are calculated locally from Hive entries.
- The analysis includes mean mood, population standard deviation, linear trend
  per day, trigger impact (only deltas greater than +1 or less than -1), common
  feelings, and the three highest and lowest mood samples.
- The **Analysis JSON** section exposes a compact, structured payload. Raw
  journal entries are not sent to an AI model; qualitative synthesis can be
  added later using this payload.
- `MoodAnalysis.toAiMap()` selects only trigger correlations and high/low
  samples, and excludes journal notes. A Firebase callable-function scaffold
  for optional Gemini insights is in [`functions/README.md`](./functions/README.md).

## Commit email notifications

Both email workflows use repository actions secrets configured under
**Settings → Secrets and variables → Actions**:

- `SMTP_HOST`
- `SMTP_PORT` (`465` for SSL or another port that supports STARTTLS, typically `587`)
- `SMTP_USERNAME`
- `SMTP_PASSWORD`
- `SMTP_FROM` (the authenticated email address or an address authorized by the provider)

The push workflow sends only the latest pushed commit message to the pusher's
email address provided in the GitHub push event. The pull request workflow sends
to the private recipient configured as `SMTP_TO`.
