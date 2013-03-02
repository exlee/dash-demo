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

    unique_data_points = []

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
          expand_points.push([x,y,item])

      expand_x = d3.scale.linear()
      .domain([0, expand_points.length-1])
      .range([scope.x(x)-100+margin, scope.x(x)+100-margin])
      
      expand.append("rect")
      .attr("x", scope.x(x)-100)
      .attr("y", scope.y(y)-50)
      .attr("rx", 5)
      .attr("ry", 5)
      .attr("width", 200)
      .attr("height", 100)
      .attr("stroke", d3.rgb("#57A8FF"))
      .attr("stroke-width", 2)
      .attr("opacity", 0)
      .transition()
      .attr("opacity", 1)

      expand.append("text")
      .attr("x", scope.x(x)-95)
      .attr("y", scope.y(y)-35)
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
          d3.rgb(d[2].category)
      )
      .attr("r", 5)
      .on("click",
        (d,i) ->
          scope.click(id: d[2].id)
      )
      .attr("opacity", 0)
      .transition()
      .attr("opacity", 1)


    scope.draw = ->
      dup_count = {}
      for item in scope.itm
        x = item["x"]
        y = item["y"]
        if (
          x >= scope.plot.minX and
          x <= scope.plot.maxX and
          y >= scope.plot.minY and
          y <= scope.plot.maxY and
          scope.cats[item.category].active
          )

          # Checking for duplicates
          coords = x+"|"+y
          if dup_count[coords]
            dup_count[coords] += 1
          else
            dup_count[coords] = 1

      for item in scope.itm
        x = item["x"]
        y = item["y"]
        item.deletion = true
        if (
          x >= scope.plot.minX and
          x <= scope.plot.maxX and
          y >= scope.plot.minY and
          y <= scope.plot.maxY
          )

          found = false
          if unique_data_points.length > 0
            for d in unique_data_points
              if d[0] == x and
              d[1] == y and
              d[2].category == item.category

                found = true
                if !scope.cats[item.category].active or
                dup_count[x+"|"+y] == 1
                  d[2].deletion = true
                else
                  d[2].deletion = false

          if not found and scope.cats[item.category].active and
          dup_count[x+"|"+y] == 1
            item.deletion = false
            unique_data_points.push([x,y,item])

      orig_length = unique_data_points.length
      iter = 0
      console.group("Removal", scope.plot.id)
      while iter < orig_length
        if unique_data_points[iter][2]["deletion"] == true
          console.group("Removed item")
          console.log("X", unique_data_points[iter][0])
          console.log("Y", unique_data_points[iter][1])
          console.log("ID", unique_data_points[iter][2].id)
          console.log("Cat", unique_data_points[iter][2].category)
          console.groupEnd()
          unique_data_points.remove(iter)
          orig_length--
        else
          iter++
      console.groupEnd()
        

      # Draw unique
      unique = vis
      .select("g.unique")
      .selectAll("circle")
      .data(unique_data_points)

      unique.enter()
      .append("circle")
      .attr("cx",
        (d) -> scope.x(d[0])
      )
      .attr("cy", height-margin)
      .attr("stroke",
        (d) ->
          d3.rgb(d[2].category)
      )
      .attr("r", 5)
      .on("click",
        (d,i) ->
          scope.click(id: d[2].id)
      )
      .attr("opacity", 0)
      .transition()
      .duration(800)
      .attr("opacity", 1)
      .attr("cy",
        (d) -> scope.y(d[1])
      )

      unique.exit()
      .transition()
      .duration(800)
      .attr("cy", margin)
      .attr("opacity", 0)
      .remove()

      n_dup_count = []
      for key,value of dup_count
        if value > 1
          n_dup_count.push( [key, value] )
      

      # Draw duplicate
      duplicate = vis
      .select("g.duplicate")
      .selectAll("rect")
      .data(n_dup_count)

      duplicate
      .enter()
      .append("rect")
      .attr("x",
        (d) -> scope.x(d[0].split("|")[0])-12
      )
      .attr("y",
        (d) -> scope.y(d[0].split("|")[1])-12
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
          x = parseInt(d[0].split("|")[0])
          y = parseInt(d[0].split("|")[1])
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
      .text((d) -> d[1])
      .attr "x",
        (d) ->
          x = d[0].split("|")[0]
          scope.x(x)-5
      .attr "y",
        (d) ->
          y = d[0].split("|")[1]
          scope.y(y)+5
      .attr("fill", d3.rgb("black"))
      .attr("font-family", "sans-serif")
      .attr("font-size", "16px")
      .attr("font-weight", "bold")
      .attr("opacity", 0)
      .on("click",
        (d) ->
          x = parseInt(d[0].split("|")[0])
          y = parseInt(d[0].split("|")[1])
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
