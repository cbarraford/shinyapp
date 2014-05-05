shinyapp = angular.module('shinyapp', [])

shinyapp.config ($locationProvider) ->
  $locationProvider.html5Mode(true)

#### Factories ####
shinyapp.factory 'chargifyPaymentFactory', ($log, $http) ->
  factory = {}
  factory.get = (id) ->
    $http.get("/api/chargify/payment_profiles/#{id}")
  factory.create = (payment) ->
    $http.post('/api/chargify/payment_profiles', payment)
  factory.update = (id, payment) ->
    $http.put("/api/chargify/payment_profiles/#{id}", payment)
  factory.delete = (id) ->
    $http.delete("/api/chargify/payment_profiles/#{id}")
  factory

shinyapp.factory 'chargifyCustomerFactory', ($log, $http) ->
  factory = {}
  factory.get = ->
    $http.get('/api/chargify/customer')
  factory.create = (customer) ->
    $http.post('/api/chargify/customer', customer)
  factory.update = (customer) ->
    $http.put('/api/chargify/customer', customer)
  factory.delete = ->
    $http.delete('/api/chargify/customer')
  factory

shinyapp.factory 'chargifySubscriptionFactory', ($log, $http) ->
  factory = {}
  factory.get = ->
    $http.get('/api/chargify/subscription')
  factory.create = ->
    $http.post('/api/chargify/subscription')
  factory.update = ->
    $http.put('/api/chargify/subscription')
  factory.delete = ->
    $http.delete('/api/chargify/subscription')
  factory

shinyapp.factory 'userFactory', ($log, $http) ->
  factory = {}

  factory.get = ->
    $http.get("/api/user")

  factory.create = (json) ->
    $http.post("/create", json)

  factory.update = (json) ->
    $http.put("/api/user", json)

  factory.delete = ->
    $http.delete("/api/user")

  factory.subscriptions = ->
    $http.get("/api/user/subscriptions")
  factory

#### Controllers ####
shinyapp.controller 'indexController', ($scope, $log, $location) ->

  # goto url fuction
  $scope.go = (path) ->
    window.location.href = path

shinyapp.controller 'signupController', ($scope, $log, $location, userFactory) ->

  # goto url fuction
  $scope.go = (path) ->
    window.location.href = path

  $scope.signup = ->
    $log.info('signing up')
    $log.info($scope.user)
    userFactory.create($scope.user).success( (data, status, headers, config) ->
      $log.info("Successfully signed up new user")
      $scope.go('/success')
    ).error( (data, status, headers, config) ->
      $log.error("Failed to signup new user")
      alert "Failed to signup new user"
    )

shinyapp.controller 'accountInfoController', ($scope, $log, $location, userFactory) ->
  userFactory.get().success( (data, status, headers, config) ->
    $scope.user = data
    $log.info("got account info")
  ).error( (data, status, headers, config) ->
    $log.error('Failed to get account info')
  )

shinyapp.controller 'accountPlanController', ($scope, $log, $location, userFactory, chargifySubscriptionFactory) ->

  userFactory.get().success( (data, status, headers, config) ->
    $scope.user = data
  ).error( (data, status, headers, config) ->
    $log.error('Failed to get account info')
  )

  userFactory.subscriptions().success( (data, status, headers, config) ->
    $scope.subscriptions = data
    $scope.plan = 'free' # set default
    for subscription in data
      $scope.plan = subscription.subscription.product.handle
  ).error( (data, status, headers, config) ->
    $log.error('Failed to get subscriptions')
  )

  $scope.updateplan = ->
    if $scope.plan != 'free'
      if $scope.user.chargify_id?
        
      else
        alert 'Cannot change your plan til you update your billing information'

shinyapp.controller 'accountBillingController', ($scope, $log, $location, userFactory, chargifyPaymentFactory, chargifyCustomerFactory, chargifySubscriptionFactory) ->
  userFactory.get().success( (data, status, headers, config) ->
    $scope.user = data
  ).error( (data, status, headers, config) ->
    $log.error('Failed to get account info')
  )

  userFactory.subscriptions().success( (data, status, headers, config) ->
    $scope.subscriptions = data
    if data.length > 0
      $scope.billing = data[0][data[0].payment_type]
    else
      $scope.billing = {}
  ).error( (data, status, headers, config) ->
    $log.error('Failed to get subscriptions')
  )

  updateBilling = ->
    if $scope.user.chargify_id?

    else
      
  createCustomer = ->
    userFactory.get().success( (data, status, headers, config) ->
      user = data
      customer = {}
      customer.first_name = user.first
      customer.last_name = user.last
      customer.email = user.email
      customer.organization = user.org
      customer.reference = user.username
      chargifyCustomerFactory.create(customer).success( (data, status, headers, config) ->
        $log.info('created customer')
        user.chargify_id = data.id
        userFactory.update(user).success( (data, status, headers, config) ->
          $log.info('created customer and updated user')
        ).error( (data, status, headers, config) ->
          $log.error('failed to update user')
        )
      ).error( (data, status, headers, config) ->
        $log.error('failed to create customer')
      )
    ).error( (data, status, headers, config) ->
      $log.error('Failed to get account info')
    )
