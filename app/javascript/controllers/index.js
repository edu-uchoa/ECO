import { application } from "controllers/application"

import NavbarController from "controllers/navbar_controller"
application.register("navbar", NavbarController)

import MapController from "controllers/map_controller"
application.register("map", MapController)

import HelloController from "controllers/hello_controller"
application.register("hello", HelloController)
