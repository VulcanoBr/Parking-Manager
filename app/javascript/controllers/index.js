import { application } from './application'

import AlertController from './alert_controller'
application.register('alert', AlertController)

import HelloController from './hello_controller'
application.register('hello', HelloController)

import ParkingFormController from './parking_form_controller'
application.register('parking-form', ParkingFormController)
