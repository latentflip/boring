require ['jquery', 'd3', 'underscore'], ($,d3,_) ->

  c =
    width: $(document).width()*0.98
    height: $(document).height()*0.97
    transitionLength: 2000

  svg = d3.select('body').append('svg')
            .attr('width', c.width)
            .attr('height', c.height)

  countries_g = svg.append('svg:g')
                  .attr('class', 'countries')

  users = svg.selectAll('circle.user')
                .data([], (d)->d.user_id)
  users = null
  stats = {}

  
  listUsers = ->
    perColumn = 20
    spacing = c.height/perColumn
    columnSpacing = c.width/5
    users.append('text')
            .text( (d)->d.screen_name)
            .attr('y', (d,i)->(i%perColumn)*spacing)
            .attr('x', (d,i)->
              colN = Math.floor(i/perColumn)
              colN*columnSpacing
            )

  circleTweetCount = ->
    users.append('circle')
          .transition().duration(c.transitionLength)
            .attr('r', (d)->d.statuses_count)
            .attr('cx', c.width/2)
            .attr('cy', c.height*0.75)

    users.select('text')
        .transition().duration(c.transitionLength)
          .text( (d)->d.screen_name)
          .style('text-anchor', 'middle')
          .attr('x', c.width/2)
          .attr('y', (d) -> (c.height*0.75)-d.statuses_count )
          .attr('transform', (d,i) ->
            d = ((i*5)%90) - 45
            cx = c.width/2
            cy = c.height*0.75
            "rotate(#{d},#{cx},#{cy})"
          )
    
  scaleTweetCount = ->
    _y = d3.scale.linear()
            .domain(stats.statuses_count)
            .range([0, c.height])
    y = (d,i) -> c.height - _y(d,i)
            
    users.select('circle')
        .transition().duration(c.transitionLength)
          .attr('r', 5)
          .attr('cy', (d)->y(d.statuses_count) )

    users.select('text')
        .transition().duration(c.transitionLength)
          .attr('x', (c.width/2)+3)
          .attr('y', (d)->y(d.statuses_count) )
          .style('text-anchor', 'start')
          .attr('transform', (d)->"rotate(0)")#, #{x(d.statuses_count)}, #{c.height/2})")

  scaleTweetCountLog = ->
    _y = d3.scale.linear()
            .domain([stats.statuses_count[0], stats.statuses_count[1]/1000])
            .range([0, c.height])
    y = (d,i) -> c.height - _y(d,i)
            
    users.select('circle')
        .transition().duration(c.transitionLength)
          .attr('r', 5)
          .attr('cy', (d)->y(d.statuses_count) )

    users.select('text')
        .transition().duration(c.transitionLength)
          .attr('y', (d)->y(d.statuses_count) )


  addAxes = ->
    _y = d3.scale.linear()
            .domain(stats.statuses_count)
            .range([0, c.height])
    y = (d,i) -> c.height - _y(d,i)

    x = d3.time.scale()
            .domain(stats.signed_up)
            .range([0, c.width])

    axis = svg.append('svg:g')
          .attr('class', 'axis')

    axis.append('text')
          .text('Joined recently')
          .style('text-anchor', 'end')
          .attr('x', c.width - 20)
          .attr('y', c.height/2 - 10)

    axis.append('text')
          .text('Joined ages ago')
          .style('text-anchor', 'start')
          .attr('x', 20)
          .attr('y', c.height/2 - 10)

    axis.append('text')
          .text('Loads a tweets')
          .style('text-anchor', 'end')
          .attr('y', 20)
          .attr('x', c.width/2 - 10)

    axis.append('text')
          .text('Nay tweets')
          .style('text-anchor', 'end')
          .attr('y', c.height - 20)
          .attr('x', c.width/2 - 10)

    axis.append('line')
          .attr('y1', c.height/2+0.5)
          .attr('y2', c.height/2+0.5)
          .attr('x1', 0)
          .attr('x2', c.width)

    axis.append('line')
          .attr('x1', c.width/2+0.5)
          .attr('x2', c.width/2+0.5)
          .attr('y1', 0)
          .attr('y2', c.height)

  addAxesAnnotations = ->
    svg.select('g.axis').append('text')
          .text('Too keen')
          .attr('x', c.width*0.75)
          .attr('y', c.height*0.25)
    svg.select('g.axis').append('text')
          .text('Old Bores')
          .attr('x', c.width*0.25)
          .attr('y', c.height*0.25)
    svg.select('g.axis').append('text')
          .text('Shy and retiring')
          .attr('x', c.width*0.25)
          .attr('y', c.height*0.75)
    svg.select('g.axis').append('text')
          .text('Learning the ropes')
          .attr('x', c.width*0.75)
          .attr('y', c.height*0.75)


  removeAxes = ->
    svg.select('g.axis').remove()


  scatterPlot = ->
    addAxes()
    _y = d3.scale.linear()
            .domain(stats.statuses_count)
            .range([0, c.height])
    y = (d,i) -> c.height - _y(d,i)

    x = d3.time.scale()
            .domain(stats.signed_up)
            .range([0, c.width])


    users.select('circle')
        .transition().duration(c.transitionLength)
          .attr('cx', (d)->x(d.signed_up) )
          .attr('cy', (d)->y(d.statuses_count) )

    users.select('text')
        .transition().duration(c.transitionLength)
          .attr('x', (d)->x(d.signed_up) )
          .attr('y', (d)->y(d.statuses_count) )

  geoTweet = ->
    origin = [-3.22, 55.95]
    projection = d3.geo.azimuthal()
                    .scale(10)
                    .origin(origin)
                    .mode('orthographic')
                    .translate([c.width/2, c.height/2])

    path = d3.geo.path()
                .projection(projection)
                .pointRadius(3)

    circle = d3.geo.greatCircle()
              .origin(projection.origin())

    clip = (d) =>
      path(circle.clip(d))


    d3.json 'world-countries.json', (collection) =>
      redraw = ->
        countries_g.selectAll('path')
                    .attr('d', clip)
        users.select('circle')
                .attr('cx', (d)->
                  projection(d.geocoords)[0]
                )
                .attr('cy', (d)->
                  projection(d.geocoords)[1]
                )
        users.select('text')
                  .attr('x', (d)->
                    projection(d.geocoords)[0]
                  )
                  .attr('y', (d)->
                    projection(d.geocoords)[1]
                  )
                  .attr('transform', (d,i) ->
                    angle = (i*5)%360
                    p = projection(d.geocoords)
                    if angle > 180
                      "rotate(#{angle},#{p[0]},#{p[1]})"
                    else
                      "rotate(#{angle},#{p[0]},#{p[1]})"
                  )

      spun = 0
      delta = 40
      spinTimeLength = 6000
      scaleTimeLength = 6000
      originalOrigin = projection.origin()
      originalScale = projection.scale()
      ease = d3.ease('elastic')
      sease = d3.ease('cubic-in')


      spin = (timestep) ->
        spun = 360*ease(timestep/spinTimeLength)
        scale = originalScale+10000*sease(timestep/scaleTimeLength)

        origin = [originalOrigin[0] + spun, originalOrigin[1]]
        projection.origin origin
        circle.origin origin
        projection.scale scale
        redraw()

        if timestep >= spinTimeLength and timestep >= scaleTimeLength
          true
        else
          false

      startSpin = ->
        d3.timer spin

      countries = countries_g.selectAll('path')
                  .data(collection.features)
                .enter().append('svg:path')
                  .attr('d', clip)

      users.select('text')
              .transition().duration(2000)
                .attr('x', (d)->
                  projection(d.geocoords)[0]
                )
                .attr('y', (d)->
                  projection(d.geocoords)[1]
                )
                .attr('transform', (d,i) ->
                  angle = (i*5)%360
                  p = projection(d.geocoords)
                  "rotate(#{angle},#{p[0]},#{p[1]})"
                )
                .style('font-size', '12px')
                #  d = 10
                #  p = projection(d.geocoords)
                #  "rotate(#{d},#{p[0]},#{p[1]})"
                #)

      users.select('circle')
          .transition().duration(2000)
            .attr('r', 3)
            .attr('cx', (d)->
              projection(d.geocoords)[0]
            )
            .attr('cy', (d)->
              projection(d.geocoords)[1]
            )
            .each('end', startSpin)

  slide = (text) ->
    ->
      slide = svg.append('svg:g')
                  .attr('class', 'slide')
      
      slide.append('text')
              .text(text)
              .style('text-anchor', 'middle')
              .attr('y', c.height/2)
              .attr('x', c.width+500)
            .transition().duration(c.transitionLength)
              .attr('x', c.width/2)

  explode = ->
    svg.selectAll('text')
          .transition().duration(c.transitionLength)
            .attr('x', -500)
          .remove()
    svg.selectAll('path')
          .transition().duration(c.transitionLength)
            .attr('transform', "translate(-50000,0)")
          .remove()
    svg.selectAll('circle')
          .transition().duration(c.transitionLength)
            .attr('cx', -500)
          .remove()

  d3.json 'locations.json', (locations) ->
    d3.json 'users.json', (coll) ->
      coll = coll.map (u) ->
        u.geocoords = locations[u.id]
        u.signed_up = new Date Date.parse(u.created_at)
        u

      coll = coll.filter (u) -> u.geocoords
      
      coll = coll[0..100]
      coll = _.sortBy coll, (u)->u.statuses_count

      users = svg.selectAll('g.user')
                    .data(coll, (d)->d.user_id)
      users.enter()
              .append('svg:g')
              .attr('class', 'user')

      stats.statuses_count = d3.extent(coll, (d)->d.statuses_count)
      stats.signed_up = d3.extent(coll, (d)->d.signed_up)
      
      currSlide=0
      slides = []
      nextSlide = ->
        slide = svg.selectAll('g.slide')
        if slide[0].length > 0
          slide.select('text')
              .transition().duration(500)
                .attr('x', -500)
              .remove()
          slides[currSlide]()
        else
          slides[currSlide]()
        currSlide++

      slides.push slide("Hello")
      slides.push slide("Tweets")
      slides.push slide("How many?")
      slides.push listUsers
      slides.push circleTweetCount
      slides.push scaleTweetCount
      #push scaleTweetCountLog
      #slides.push addAxes
      slides.push scatterPlot
      slides.push addAxesAnnotations
      slides.push removeAxes
      slides.push geoTweet
      slides.push explode
      slides.push slide("So like, wth?")
      slides.push slide("So like, wth?")
      
      nextSlide()

      svg.on('click', nextSlide)
