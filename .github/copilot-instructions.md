# Copilot instructions for prison-visits-public

## Architecture and flow (read before changing booking logic)
- This is a Rails 7.2 app serving the public prison-visit request journey; it is intentionally **stateless** and mostly delegates business operations to external APIs.
- Main public flow is locale-scoped (`/:locale`, `en|cy`) and starts at `BookingRequestsController` (`app/controllers/booking_requests_controller.rb`).
- Multi-step journey is orchestrated by `StepsProcessor` (`app/services/steps_processor.rb`) with fixed order: `prisoner_step -> slots_step -> visitors_step -> confirmation_step`.
- Step objects are in-memory ActiveModel objects (`MemoryModel` concern) rather than ActiveRecord (`app/models/concerns/memory_model.rb`).
- Persisted booking happens only once all steps are complete: `StepsProcessor#execute!` -> `BookingRequestCreator#create!` -> `PrisonVisits::Api#request_visit`.

## Service boundaries and integration points
- Public app talks to PVB2/staff API through `PrisonVisits::Api` and `PrisonVisits::Client` (`app/services/prison_visits/api.rb`, `app/services/prison_visits/client.rb`).
- `Rails.configuration.use_staff_api` switches data source:
  - `true`: HTTP calls to `/api/*` on `PRISON_VISITS_API`
  - `false`: local `Staff::*` ActiveRecord models/services as fallback
- Additional integrations exist for NOMIS and VSIP (`app/services/nomis/*`, `app/services/vsip/*`), surfaced in health checks (`app/controllers/health_controller.rb`).
- Request tracing is important: `ApplicationController#store_request_id` sets `RequestStore[:request_id]`; API client forwards this as `X-Request-Id`.

## Step-form conventions (critical)
- State is carried between pages via hidden fields in partials (`app/views/booking_requests/_hidden_*_step.html.erb`), not server session.
- If you add/rename step attributes, update **all** of:
  - step model attributes/validation (`app/models/*_step.rb`)
  - strong params (`BookingRequestsController#sanitised_steps_params`)
  - hidden partials for downstream steps
  - step view template name (`render step_name` relies on naming match)
- Avoid unnecessary API calls in validations; follow existing guards such as `PrisonerStep#prevent_api_call?`.

## Testing and quality workflow
- Use the same order as CI (`.github/workflows/pipeline.yml`):
  1. `bin/rails db:create db:schema:load`
  2. `bundle exec brakeman`
  3. `bundle exec rubocop`
  4. `bundle exec rspec`
- Coverage gate is strict (`SimpleCov.minimum_coverage 100` in `spec/spec_helper.rb`).
- Repo convention: stub/mock at API-client boundary (`pvb_api` helper), not raw HTTP, for most tests.
- Only API client specs should use VCR cassettes (`spec/services/prison_visits/api_spec.rb`).
- Feature specs use Cuprite (`spec/support/features/cuprite_setup.rb`); set `HEADLESS=no` for interactive debugging.

## UI and frontend conventions
- Frontend is Sprockets + jQuery modules (`app/assets/javascripts/application.js`), not modern JS bundlers.
- Slot picker behavior is custom and complex (`app/assets/javascripts/modules/slotpicker/*`); prefer surgical changes.
- Keep GOV.UK styling patterns used in current SCSS stack (`app/assets/stylesheets/application.scss`).

## Practical defaults for agents
- Prefer minimal, localized edits in existing patterns; do not introduce new frameworks.
- Preserve locale-aware routes and translations (`config/routes.rb`, `config/locales/{en,cy}`).
- For booking journey changes, run at least the relevant model/controller/feature specs plus full `rspec` if feasible.
- If touching API integration code, verify error handling paths (`PrisonVisits::APIError`, `APINotFound`) and health endpoints.

## Common change checklists
- **Adding/changing step fields**
  - Update step model attributes/validations (`app/models/*_step.rb`).
  - Update strong params (`BookingRequestsController#sanitised_steps_params`).
  - Update hidden carry-forward partials (`app/views/booking_requests/_hidden_*_step.html.erb`).
  - Update step view inputs and relevant model/controller/feature specs.
- **Touching API integration code**
  - Keep both `use_staff_api` paths working (`PrisonVisits::Api` HTTP + `Staff::*` fallback).
  - Preserve request context headers (`Accept-Language`, `X-Request-Id`) in `PrisonVisits::Client`.
  - Preserve controller-facing error behavior for `PrisonVisits::APIError` and `APINotFound`.
  - Keep VCR coverage limited to `spec/services/prison_visits/api_spec.rb`; stub `pvb_api` elsewhere.