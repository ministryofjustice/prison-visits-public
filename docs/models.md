# Models

These models are not persisted but have attributes (via Virtus) and validations
to represent each step in the journey of requesting a visit.

## `PrisonerStep`

The first step: information about the prisoner, including the prison.

## `VisitorsStep`

The second step: information about the primary visitor and any additional
visitors.

## `SlotsStep`

The third step: allows selection of slots for the prison.

## `ConfirmationStep`

This step has only one attribute (`confirmed`) and exists only to facilitate
displaying a confirmation page in the same way as the preceding steps.
