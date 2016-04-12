# Visit someone in prison

This application contains the public interface for booking a prison visit.

It is stateless and relies entirely on the prison visits booking API exposed by [ministryofjustice/prison-visits-2](https://github.com/ministryofjustice/prison-visits-2), which exposes prison information, slot availability, and allows booking and managing a visit.

The codebase was split from [ministryofjustice/prison-visits-2](https://github.com/ministryofjustice/prison-visits-2), which previously was also responsible for serving the public interface.

## Notes on the code

### Steps

These models are not persisted but have attributes (via Virtus) and validations
to represent each step in the journey of requesting a visit.

#### `PrisonerStep`

The first step: information about the prisoner, including the prison.

#### `VisitorsStep`

The second step: information about the primary visitor and any additional
visitors.

#### `SlotsStep`

The third step: allows selection of slots for the prison.

#### `ConfirmationStep`

This step has only one attribute (`confirmed`) and exists only to facilitate
displaying a confirmation page in the same way as the preceding steps.

### Requesting a visit

The `BookingRequestsController` has only two actions, `index` and `create`,
which means only one path, differentiated by `GET` or `POST`. It is completely
stateless: progression through the steps is determined by the availability of
complete information in the preceding steps, passed either as user-completed
form fields or (in the case of preceding steps) as hidden fields.

The logic of processing steps and determining which step has been reached is
handled by the `StepsProcessor` class.

On an initial `GET`, the first step (`PrisonerStep`) is instantiated with no
parameters.

Thereafter, on a `POST` request, each step in turn is instantiated using the
named parameters for that step (if available). The first incomplete step (where
incompleteness is determined by the complete absence of parameters for that
step, or by the invalidity of those supplied) determines the template to be
rendered.

Finally, if all steps are complete, a `Visit` is created by
`BookingRequestCreator` and the `completed` template is rendered.

## Configuration

### Environment variables

#### `GA_TRACKING_ID`

Google Analytics ID, used for the Performance Platform.

#### `GOVUK_START_PAGE`

Visiting `/` will redirect to this URL, if supplied, or the new booking page
otherwise. On production, this must be set to
[https://www.gov.uk/prison-visits](https://www.gov.uk/prison-visits), the
official start page for the service.

#### `SECRET_KEY_BASE`

This key is used to verify the integrity of signed cookies. If it is changed,
all old signed cookies will become invalid.

Make sure the secret is at least 30 characters and all random, no regular words
or you’ll be exposed to dictionary attacks. You can use `rake secret` to
generate a secure secret key.

#### `SMTP_USERNAME`, `SMTP_PASSWORD`

Now only used to configure the Sendgrid API client.

#### `ENABLE_SENDGRID_VALIDATIONS` (optional)

If specified it will enable the email validations that use Sendgrid in the `EmailChecker` class.

#### `EMAIL_DOMAIN`

This is the email domain used in the generation of email addresses shown on the site (currently only the no-reply address from which to expect bookings).

On production this must be set to `email.prisonvisits.service.gov.uk`.

#### `ASSET_HOST` (optional)

If specified this will configure Rails' `config.asset_host`, resulting in all asset URLs pointing to this host.

#### `SENTRY_DSN` (optional)

If specified, exceptions will be sent to the given Sentry project.

### Files to be created on deployment

#### `META`

This file, located in the root directory, should be a JSON document containing
build information to be returned by `/ping.json`. e.g.:

```json
{
  "build_date": "2015-12-08T10:18:04.357122",
  "commit_id": "a444e4b05276ae7dc2b1d4224e551dfcbf768795"
}
```

## Welsh translation

NOMS Wales manages translations via Transifex. This means that we:

* Write English translations in the YAML files as usual.
* Push the English up to Transifex.
* Pull down Welsh from Transifex.

In order to use Transifex, you need the client and an account.

The Transifex client is written in Python and can be installed via

```sh
$ pip install transifex-client
```

You will also need to [configure the user account for the
client](http://docs.transifex.com/client/config/#transifexrc).

To push the English translations to Transifex, use

```sh
tx push -s
```

To pull Welsh, use

```sh
tx pull -l cy
```

Then commit as usual.
