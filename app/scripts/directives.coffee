app_module.directive('pkPlot', ->
  restrict: 'E'
  replace: false
  scope:
    "itm": "="
    "plot": "="
    "click": "&"
    "cats": "="
    "id": "@"
  link: (scope, element, attrs, controller) ->
    vis = {}
    width = 0
    height = 0
    margin = 20
    softmargin = 10

    $(window).resize ->
      scope.refreshVis()
    $(window).load ->
      scope.refreshVis()

    scope.$watch("cats",
      ->
        scope.refreshVis()
      , true)
    scope.$watch("plot.refresh",
      ->
        scope.refreshVis()
      ,true
    )


    scope.refreshVis = ->
      a = d3.select(element[0]).select('svg').remove()
      vis = d3.select(element[0])
      .append("svg")
      .attr("width", (d,i) -> element.css('width'))
      .attr("height", (d,i) -> element.css('height'))

      width = parseInt(element.css('width'))
      height = parseInt(element.css('height'))

      scope.x = d3.scale.linear()
      .domain([scope.plot.minX, scope.plot.maxX])
      .range([0+margin, width-margin])

      scope.y = d3.scale.linear()
      .domain([scope.plot.minY, scope.plot.maxY])
      .range([0+margin, height-margin])
      

      scope.draw()

    scope.draw = ->
      vis.append("line")
      .attr("x1", 0)
      .attr("y1", 0)
      .attr("x2", 0)
      .attr("y2", height-softmargin)
      .attr("stroke", d3.rgb("black"))
      .attr("stroke-width", 3)

      vis.append("line")
      .attr("x1", 0)
      .attr("y1", height-softmargin)
      .attr("x2", width-softmargin)
      .attr("y2", height-softmargin)
      .attr("stroke", d3.rgb("black"))
      .attr("stroke-width", 2)
      
      data_points = []
      for item in scope.itm
        x = item["Math.sin(x)"]
        y = item["Math.sin(5*x)*189.32"]
        if (
          x >= scope.plot.minX and
          x <= scope.plot.maxX and
          y >= scope.plot.minY and
          y <= scope.plot.maxY and
          scope.cats[item.category].active
          )
          data_points.push([x,y, item])

      vis
      .selectAll("circle")
      .data(data_points)
      .enter()
      .append("circle")
      .attr("cx",
        (d) -> scope.x(d[0])
      )
      .attr("cy",
        (d) -> scope.y(d[1])
      )
      .attr("fill", d3.rgb("white"))
      .attr("stroke",
        (d) ->
          d3.rgb(d[2].category)
      )
      .attr("stroke-width", 2)
      .attr("r", 5)
      .on("click",
        (d,i) ->
          scope.click(id: d[2].id)
      )

)
