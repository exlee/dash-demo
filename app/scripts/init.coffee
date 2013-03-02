angular.module('App', ['ui'])
.config(
  [
    '$routeProvider',
    ($routeProvider) ->
      $routeProvider
      .when('/',
        controller: 'DashboardController'
        templateUrl: "partials/dashboard.html"
      )
      .otherwise redirectTo: '/'
  ]
)
.run(
  [
    "$rootScope",
    ($rootScope) ->
      $rootScope.resizeContainers = ->
        working_area = $(window).height() - $('#header').height()
        $('#content').css {
          'min-height': working_area*0.7
          'max-height': working_area*0.7
          'height': working_area*0.7
        }
        $('#footer').css {
          'min-height': working_area*0.3
          'max-height': working_area*0.3
          'height': working_area*0.3
        }

      $(window).resize (e) ->
        $rootScope.resizeContainers()

      $(window).load (e) ->
        $rootScope.resizeContainers()
  ]
)
