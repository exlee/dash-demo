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
    init = false

    $(window).resize ->
      scope.refreshVis()
    $(window).load ->
      scope.refreshVis()

    scope.$watch("cats",
      ->
        if init == true
          scope.draw()
      , true)

    scope.$watch("plot.refresh",
      (val) ->
        if (val) > 3
          scope.refreshVis()
      ,true
    )

    scope.unique_data_points = []

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
      .range([height-margin, 0+margin])
      
      vis.append("g").attr("class", "unique")
      vis.append("g").attr("class", "duplicate")

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

      init = true
      scope.draw()

    scope.expandGroup = (x,y) ->
      vis.select("g.expand").remove()
      expand = vis.append("g").attr("class", "expand")

      expand_points = []

      for item in scope.itm
        if item.x == x and item.y == y and
        scope.cats[item.category].active
          expand_points.push(item)

      expand_x = d3.scale.linear()
      .domain([0, expand_points.length-1])
      .range([scope.x(x)-40+margin, scope.x(x)+40-margin])
      
      expand.append("rect")
      .attr("x", scope.x(x)-40)
      .attr("y", scope.y(y)-20)
      .attr("rx", 5)
      .attr("ry", 5)
      .attr("width", 80)
      .attr("height", 40)
      .attr("stroke", d3.rgb("#57A8FF"))
      .attr("stroke-width", 2)
      .attr("opacity", 0)
      .transition()
      .attr("opacity", 1)

      expand.append("text")
      .attr("x", scope.x(x)-38)
      .attr("y", scope.y(y)-6)
      .text("X")
      .attr("cursor","pointer")
      .on("click",
      ->
        expand
        .attr("opacity", 1)
        .transition()
        .attr("opacity", 0)
        .remove()
      )


      expand
      .selectAll("circle")
      .data(expand_points)
      .enter()
      .append("circle")
      .attr("cx",
        (d,i) -> expand_x(i)
      )
      .attr("cy", scope.y(y))
      .attr("stroke",
        (d) ->
          d3.rgb(d.category)
      )
      .attr("r", 5)
      .on("click",
        (d,i) ->
          scope.click(id: d.id)
      )
      .attr("opacity", 0)
      .transition()
      .attr("opacity", 1)

    scope.canBeDisplayed = (item, duplicates=undefined) ->
      main = item.x >= scope.plot.minX and
      item.x <= scope.plot.maxX and
      item.y >= scope.plot.minY and
      item.y <= scope.plot.maxY and scope.cats[item.category].active

      if(duplicates)
        return main and duplicates[item.x+"|"+item.y] == 1
      else
        return main

    scope.draw = ->
      duplicates = {}
      # Deleting everything
      for item in scope.unique_data_points
        item.delete = true


      # Counting duplicates
      for item in scope.itm
        if (scope.canBeDisplayed(item))
          key = item.x+"|"+item.y
          if duplicates[key]
            duplicates[key] += 1
          else
            duplicates[key] = 1

      # Generating unique values
      for item in scope.itm
        if scope.canBeDisplayed(item, duplicates)
          found = false
          for d in scope.unique_data_points
            if d == item
              found = true
              d.delete = false

          if not found
            item.delete = false
            scope.unique_data_points.push(item)

      new_arr = []
      for item in scope.unique_data_points
        if item.delete == false
          new_arr.push(item)

      scope.unique_data_points = new_arr
      
      # Draw unique
      unique = vis
      .select("g.unique")
      .selectAll("circle")
      .data(scope.unique_data_points, (d) -> d.id)

      unique.enter()
      .append("circle")
      .attr("cx",
        (d) -> scope.x(d.x)
      )
      .attr("cy", height-margin)
      .attr("stroke",
        (d) ->
          d3.rgb(d.category)
      )
      .attr("r", 5)
      .on("click",
        (d,i) ->
          scope.click(id: d.id)
      )
      .attr("opacity", 0)
      .transition()
      .duration(800)
      .attr("opacity", 1)
      .attr("cy",
        (d) -> scope.y(d.y)
      )

      unique.exit()
      .transition()
      .duration(800)
      .attr("cy", margin)
      .attr("opacity", 0)
      .remove()

      n_dup_count = []
      for key,value of duplicates
        if value > 1
          x = parseInt(key.split("|")[0])
          y = parseInt(key.split("|")[1])
          counter = 0
          for item in scope.itm
            if item.x == x and item.y == y and scope.canBeDisplayed(item)
              counter++

          if counter > 0
            n_dup_count.push( [x,y, counter] )
      

      # Draw duplicate
      duplicate = vis
      .select("g.duplicate")
      .selectAll("rect")
      .data(n_dup_count)

      duplicate
      .enter()
      .append("rect")
      .attr("x",
        (d) -> scope.x(d[0])-12
      )
      .attr("y",
        (d) -> scope.y(d[1])-12
      )
      .attr("rx", 2)
      .attr("ry", 2)
      .attr("stroke", d3.rgb("#57A8FF"))
      .attr("stroke-width",3)
      .attr("width", 24)
      .attr("height", 24)
      .attr("fill", d3.rgb("white"))
      .attr("opacity", 0)
      .on("click",
        (d) ->
          x = d[0]
          y = d[1]
          scope.expandGroup(x,y)
      )
      .transition()
      .duration(1000)
      .attr("opacity", 1)

      duplicate.exit()
      .transition()
      .attr("opacity", 0)
      .remove()

      duplicate_text = vis
      .select("g.duplicate")
      .selectAll("text")
      .data(n_dup_count)

      duplicate_text
      .enter()
      .append("text")
      .text((d) -> d[2])
      .attr "x",
        (d) ->
          x = d[0]
          scope.x(x)-5
      .attr "y",
        (d) ->
          y = d[1]
          scope.y(y)+5
      .attr("fill", d3.rgb("black"))
      .attr("font-family", "sans-serif")
      .attr("font-size", "16px")
      .attr("font-weight", "bold")
      .attr("opacity", 0)
      .on("click",
        (d) ->
          x = d[0]
          y = d[1]
          scope.expandGroup(x,y)
      )
      .transition()
      .duration(1000)
      .attr("opacity", 1)

      duplicate_text.exit()
      .transition()
      .attr("opacity", 0)
      .remove()


)
