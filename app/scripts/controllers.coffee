DashboardController = ['$scope','$http','$routeParams',
  ($scope, $http, $routeParams) ->

    $scope.data = []
    $scope.categories = {}
    $scope.position_keys = {}
    $scope.all_categories = ""

    # Generating random data
    $scope.position_keys = [
      "Math.sin(x)"
      "Math.sin(5*x)-7.39"
    ]

    dictionaries =
      color: ["red", "blue", "white", "brown", "navy", "magenta"]
      food: ["pizza", "hotdog", "hamburger", "salad", "apple"]
      pet: ["cat", "dog", "ostrich", "chameleon", "hamster"]
      city: ["Los Angeles", "Vienna", "London", "Berlin", "New York"]
      hair: ["blond", "black", "red", "brown", "white"]

    # Calculating keys
    for key of dictionaries
      $scope.categories[key] = { class: ""}

    for x in [1..50]
      obj = {id: x}
      for key in $scope.position_keys
        if key != "id"
          obj[key] = Math.round(eval(key)*100)/100

      for key,list of dictionaries
        obj[key] = list[Math.floor(Math.random() * list.length)]

      $scope.data.push(obj)

        

    $scope.toggleCategory = (category) ->
      category.active = !category.active

      if category.active
        category.class = "active"
      else
        category.class = ""

    $scope.toggleAllCategories = ->
      if($scope.all_categories)
        for name, values of $scope.categories
          values.class = ""
          values.active = false
      else
        for name, values of $scope.categories
          values.class = "active"
          values.active = true

    $scope.$watch("categories", ->
      console.log("checked")
      all_enabled = true
      for key, value of $scope.categories
        if !(value.active)
          all_enabled = false
      if all_enabled
        $scope.all_categories = "active"
      else
        $scope.all_categories = ""
    ,true
    )

  
]
