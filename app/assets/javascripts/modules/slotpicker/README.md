# PVB slot picker

UI for selecting a slot time from a list of options from a select element

The Slot Picker expects source dates to be provided in the form of option elements with values as the slot data.

```sh
<option value="2018-09-22T09:15/10:50">Saturday 22 September 9:15am</option>
```

When a slot is selected in the calendar UI, the corresponding hidden option element is selected

## Components

### moj.slotpicker.js

This kicks-off everything by creating a new datepicker object and assigns it to an element (.js-calendar)

### moj.datepicker.js

This mainly handles events around the page (cancelling, submitting, deleting a slot etc.) and initialises the below modules

### calendar.js

This is a complicated file to follow. It builds the calendar UI and handles all the keyboard and click events of navigating and choosing dates

### helpers.js

Various helper functions that are shared between components, mainly date/time formatting

### slots.js

This builds the selection of slot times (radio buttons) once a date has been selected, handles their events and displays the chosen date and time

### source.js

This relates to the ```<select>``` element and its ```<option>``` children. It's main function is to compile and format the slot data and availability and also get/set the value
