# Configuration

## Environment variables

### `GA_TRACKING_ID`

Google Analytics ID, used for the Performance Platform.

### `GOVUK_START_PAGE`

Visiting `/` will redirect to this URL, if supplied, or the new booking page
otherwise. On production, this must be set to
[https://www.gov.uk/prison-visits](https://www.gov.uk/prison-visits), the
official start page for the service.

### `SECRET_KEY_BASE`

This key is used to verify the integrity of signed cookies. If it is changed,
all old signed cookies will become invalid.

Make sure the secret is at least 30 characters and all random, no regular words
or you’ll be exposed to dictionary attacks. You can use `rake secret` to
generate a secure secret key.

### `EMAIL_DOMAIN`

This is the email domain used in the generation of email addresses shown on the site (currently only the no-reply address from which to expect bookings).

On production this must be set to `email.prisonvisits.service.gov.uk`.

### `STAFF_SERVICE_URL`

The url for the staff service.

### `ASSET_HOST` (optional)

If specified this will configure Rails' `config.asset_host`, resulting in all asset URLs pointing to this host.

### `SENTRY_DSN` (optional)

If specified, exceptions will be sent to the given Sentry project.

### `SENTRY_JS_DSN` (optional)

If specified, Javascript exceptions will be sent to the given Sentry project.

## Files to be created on deployment

### `META`

This file, located in the root directory, should be a JSON document containing
build information to be returned by `/ping.json`. e.g.:

```json
{
  "build_date": "2015-12-08T10:18:04.357122",
  "commit_id": "a444e4b05276ae7dc2b1d4224e551dfcbf768795"
}
```