# Public database connection budget

This is the public-app part of the connection/concurrency optimisation. It is
independently deployable from the corresponding prison-visits-2 changes.

## Changes

- ActiveRecord pool sizing: DB_POOL_SIZE, then RAILS_MAX_THREADS, then five.
- HTTP client pool sizing: HTTP_POOL_SIZE, then RAILS_MAX_THREADS, then five.
- Helm rollout maxSurge changes from 100% to integer 1. Steady replicas, request
  threads, worker count and maxUnavailable remain unchanged.

Separating the pools means DB_POOL_SIZE=1 no longer also limits API clients to one
connection. Each HTTP client retains its own pool; this is not a shared cap across
all APIs. A DATABASE_URL pool parameter retains Rails' precedence over DB_POOL_SIZE
and is covered by a boot-level regression.

The application still supports both USE_STAFF_API paths. The direct Staff-model
fallback shares the visits database; this change does not switch routing modes.
Puma still uses four workers even though WEB_CONCURRENCY is imported from a
secret. Honouring that previously ignored secret could change throughput, so it is
intentionally not part of this optimisation.

## Budget

With two pods, four workers and the default pool of five, normal configured
database capacity remains 40 connections. The nominal rollout population changes
from four pods to three, reducing this app's nominal rollout budget from 80 to 60
pool slots. With the staff chart's corresponding change, the combined nominal web
rollout budget changes from 180 to 135; normal combined capacity stays 90.

These are capacity calculations, not observed sessions or memory savings.
Connections are lazy; terminating pods, jobs, consoles, autoscaling and URL/env
overrides need separate accounting. Kubernetes can retain terminating pods beyond
the nominal surge population, so this is not a strict connection cap.

At two replicas, the unchanged 20% maxUnavailable rounds down to zero. One fewer
surge pod can make deployments slower, but does not deliberately reduce healthy
steady serving capacity. The application does not need to be deployed alongside
the staff app atomically; the full combined budget applies once both are updated.

## Validation and rollback

Six actual Rails-boot cases passed: defaults, legacy thread sizing, DB-only and
HTTP-only overrides, both overrides and URL precedence. The dummy database URL
was deliberately unreachable, so these checks did not retrieve data. The final
spec location was also rechecked. Helm lint and rendered-object validation passed
for dev, preprod and prod. Full RuboCop passed; Brakeman reported zero warnings.
Full application/browser tests are left to the existing CI pipeline, without
changing its coverage policy.

No dependencies or lockfiles, schemas, database instance parameters or business
rules change. Revert the config/chart changes to roll back; replacement processes
pick up the reverted settings. Do not assume this alone makes db.t4g.small safe,
and do not lower normal web pools until request and background concurrency are
understood.
