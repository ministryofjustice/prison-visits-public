# Requesting a visit

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

See [models documentation](docs/models.md) for further information.