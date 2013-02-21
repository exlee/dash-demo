DashboardController = ['$scope','$http','$routeParams',
  ($scope, $http, $routeParams) ->

    $scope.data = []
    $scope.categories = {}
    $scope.position_keys = {}
    $scope.all_categories = ""


    plotRepr = ->
      return "(" + @minX + "," + @minY +
        ") to (" + @maxX +  "," + @maxY + ")"
    $scope.grid = {
      "Plot 1":
        id: "plot_1"
        active: true
        minX: -1
        minY: -190
        maxX: 0
        maxY: 0
        repr: plotRepr
        refresh: 0
      "Plot 2":
        id: "plot_2"
        active: true
        minX: -1
        minY: 0
        maxX: 0
        maxY: 190
        repr: plotRepr
        refresh: 0
      "Plot 3":
        id: "plot_3"
        active: true
        minX: 0
        minY: -190
        maxX: 1
        maxY: 0
        repr: plotRepr
        refresh: 0
      "Plot 4":
        id: "plot_4"
        active: true
        minX: 0
        minY: 0
        maxX: 1
        maxY: 190
        repr: plotRepr
        refresh: 0
    }



    # Generating random data

    $scope.position_keys = [
      "Math.sin(x)"
      "Math.sin(5*x)*189.32"
    ]

    dictionaries =
      color: ["red", "blue", "orange", "gold", "silver", "magenta"]

    # Calculating keys
    for key,value of dictionaries
      for item in value
        $scope.categories[item] = { class: ""}

    for x in [1..100]
      obj = {id: x}
      for key in $scope.position_keys
        if key != "id"
          obj[key] = Math.round(eval(key)*100)/100

      list = dictionaries['color']
      obj['category'] = list[Math.floor(Math.random() * list.length)]

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

    $scope.activeCategory = (category) ->
      if $scope.categories[category].active
        true
      else
        false

    $scope.resizeGrid = ->
      margin = 5
      padding = 5
      border = 2

      grid_len = 0
      for key,val of $scope.grid
        if val.active
          grid_len++
      grid_cols = Math.ceil(grid_len/2)
      if grid_len > 1
        grid_rows = 2
      else
        grid_rows = 1

      # Height depends on numer rows
      content_height = $('#content').height()
      cell_height = Math.floor(content_height/grid_cols)
      cell_height -= 2*(margin+padding+border)

      content_width = $('.plot_cell').parents('.span10').width()
      cell_width = Math.floor(content_width/grid_rows)
      cell_width -= 2*(margin+padding+border)
     

      $('.plot_cell').each ->
        $(@).css(
          "min-height": cell_height
          "max-height": cell_height
          "height": cell_height
          "width": cell_width
        )
      for key of $scope.grid
        $scope.grid[key].refresh += 1

    $scope.scrollTo = (id) ->
      if ($("#row_"+id).position().top != 0)
        scrollTo = $("#row_" + id)
        $('#footer').animate(
          scrollTop: scrollTo.offset().top -
          $("#footer").offset().top + $("#footer").scrollTop()
        ,1000)

    # Watch statements
    $scope.$watch("categories", ->
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
    $scope.$watch("grid", ->
      $scope.resizeGrid()
    ,true)

    $(document).ready ->
      $scope.toggleAllCategories()
    $(window).load ->
      $scope.resizeGrid()

    $(window).resize ->
      $scope.resizeGrid()

  
]
