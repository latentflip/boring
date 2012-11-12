require ['jquery', 'd3', 'underscore'], ($,d3,_) ->

  c =
    width: $(document).width()*0.98
    height: $(document).height()*0.97
    transitionLength: 2000

  svg = d3.select('body').append('svg')
            .attr('width', c.width)
            .attr('height', c.height)

  links_g = svg.append('svg:g')
                .attr('class', 'links')

  countries_g = svg.append('svg:g')
                  .attr('class', 'countries')

  users = svg.selectAll('circle.user')
                .data([], (d)->d.user_id)
  users = null
  stats = {}

  nextSlide = null

  
  listUsers = ->
    perColumn = 20
    spacing = (c.height-40)/perColumn
    columnSpacing = (c.width-40)/5

    users.append('circle')
            .attr('r', 5)
            .attr('cy', (d,i)->20+(i%perColumn)*spacing)
            .attr('cx', (d,i)->
              colN = Math.floor(i/perColumn)
              20+colN*columnSpacing
            )
            .style('fill', '#FF6600')

    users.append('text')
            .text( (d)->d.screen_name)
            .attr('y', (d,i)->20+(i%perColumn)*spacing+10)
            .attr('x', (d,i)->
              colN = Math.floor(i/perColumn)
              20+colN*columnSpacing
            )

  force = null
  forceGraph = ->
    d3.json 'twitterdata/links.json', (links) ->
      force = d3.layout.force()
                .charge(-50)
                .linkDistance(400)
                .size([c.width, c.height])


      find = (coll, test) ->
        for i in [0...coll.length] by 1
          return i if test(coll[i])
        return -1

      links = links.map (link) ->
        link.source = find users.data(), (u)->u.id == link.source
        link.target = find users.data(), (u)->u.id == link.target
        link.weight = link.value
        link

      links = links.filter (link)->
        link.source && link.source>0 && link.target && link.target>0

      force.nodes(users.data())
            .links(links)
            .linkStrength( (d)-> strength = d.value / d3.max(links, (d)->d.value) )
            .start()
      
      thickness = d3.scale.linear()
                      .range([0,5])
                      .domain([0, d3.max(links, (d)->d.value)])
           
      link = links_g.selectAll('line.link')
                  .data(links)
                .enter().append('line')
                    .attr('class', 'link')
                    .attr('stroke-width', (d)->thickness(d.value))
                    .attr('stroke', '#ddd')

      node = svg.selectAll('circle')
                  .attr('class', 'node')
                  .attr('r', 5)
                  .style('fill', '#FF6600')

      nodetext = svg.selectAll('text')
                    .attr('class', 'nodetext')
                    .text( (d)->d.screen_name)

      
      force.on 'tick', ->
        node.attr('cx', (d) -> d.x)
            .attr('cy', (d) -> d.y)

        nodetext.attr('x', (d) -> d.x)
                .attr('y', (d) -> d.y)

        link.attr('x1', (d) -> d.source.x)
            .attr('y1', (d) -> d.source.y)
            .attr('x2', (d) -> d.target.x)
            .attr('y2', (d) -> d.target.y)

  countDown = ->
    s = svg.append('svg:g')
                .attr('class', 'slide')


    arc = (start, end) ->
      start = (start/180)*Math.PI
      end = (end/180)*Math.PI
      d3.svg.arc()
        .innerRadius(0)
        .outerRadius(1000)
        .startAngle(start)
        .endAngle(end)()

    pie = s.append('path')
          .attr('d', arc(0,0))
          .attr('fill', '#787878')
          .attr('transform', "translate(#{c.width/2},#{c.height/2})")

    s.append('circle')
        .attr('cx', c.width/2)
        .attr('cy', c.height/2)
        .attr('r', 200)
        .style('stroke', 'rgba(255,255,255,0.8)')
        .style('stroke-width', 5)

    s.append('circle')
        .attr('cx', c.width/2)
        .attr('cy', c.height/2)
        .attr('r', 230)
        .style('stroke', 'rgba(255,255,255,0.5)')
        .style('stroke-width', 5)

    s.append('line')
        .attr('x1', 0)
        .attr('x2', c.width)
        .attr('y1', c.height/2)
        .attr('y2', c.height/2)
        .attr('stroke', '#000')
        .attr('stroke-width', 5)

    s.append('line')
        .attr('x1', c.width/2)
        .attr('x2', c.width/2)
        .attr('y1', 0)
        .attr('y2', c.height)
        .attr('stroke', '#000')
        .attr('stroke-width', 5)

    num = s.append('text')
            .text('5')
            .style('fill', '#000')
            .style('font-size', 300)
            .style('text-anchor', 'middle')
            .style('dominant-baseline', 'central')
            .attr('x', c.width/2)
            .attr('y', c.height/2)


    l = 1000
    d3.timer (n) ->
      deg = (n/l)*360
      
      count = Math.floor( n / l )
      if count % 2 == 0
        updown = 'up'
      else
        updown = 'down'

      if count >= 5
        s.transition().duration(1000)
            .attr('transform', 'translate(-5000,0)')
            .each('end', ->
              d3.selectAll('g.slide').remove()
              nextSlide()
            )
        return true
      else
        num.text(5-count)
        if updown == 'up'
          pie.attr('d', arc(0, deg%360))
        else
          pie.attr('d', arc(deg%360, 359))
        return false



  circleTweetCount = ->
    force.stop()
    svg.selectAll('line.link').remove()
    r = d3.scale.log()
            .domain(stats.statuses_count)
            .range([0, c.height*0.75])

    users.select('circle')
          .transition().duration(c.transitionLength)
            .style('fill', 'none')
            .attr('r', (d)->r(d.statuses_count))
            .attr('cx', c.width/2)
            .attr('cy', c.height*0.75)

    users.select('text')
        .transition().duration(c.transitionLength)
          .text( (d)->d.screen_name)
          .style('text-anchor', 'middle')
          .attr('x', c.width/2)
          .attr('y', (d) -> (c.height*0.75)-r(d.statuses_count) )
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
    note = (text, xp, yp, delay, duration) ->
      r=svg.select('g.axis').append('rect')
              .style('fill', '#66FF00')

      t=svg.select('g.axis').append('text')
              .text(text)
      t.attr('x', c.width*xp)
        .attr('y', c.height*yp)
        .style('text-anchor', 'middle')
        .style('opacity', 0)
      .transition().duration(duration).delay(delay)
        .style('opacity', 0.9)
        
      console.log t[0][0].clientWidth
      console.log t[0][0].clientHeight
      r.attr('width', t[0][0].clientWidth+10)
        .attr('height', t[0][0].clientHeight+10)
        .attr('x', c.width*xp - (t[0][0].clientWidth+10)/2)
        .attr('y', c.height*yp - (t[0][0].clientHeight+20)/2)
        .style('opacity', 0)
      .transition().duration(duration).delay(delay)
        .style('opacity', 0.9)

    note('Old Bores', 0.25, 0.25, 0, 1000)
    note('A bit Keen', 0.75, 0.25, 1000, 1000)
    note('Learning the ropes', 0.75, 0.75, 2000, 1000)
    note('Stalkers', 0.25, 0.75, 3000, 1000)


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
    removeAxes()
    origin = [-3.22, 55.95]
    projection = d3.geo.azimuthal()
                    .scale(100)
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
      s = svg.append('svg:g')
                  .attr('class', 'slide')
      
      s.append('text')
              .text(text)
              .style('text-anchor', 'middle')
              .attr('y', c.height/2)
              .attr('x', c.width+500)
            .transition().duration(c.transitionLength/2)
              .attr('x', c.width/2)
      return s

  philSlide = ->
    slide('@philip_roberts')()

    console.log svg.select('g.slide')
    svg.select('g.slide').append('text')
        .text('↘')
        .attr('x', c.width*0.2 - 2000)
        .attr('y', c.height*0.8 - 2000)
        .style('text-anchor', 'middle')
        .style('font-size', 200)
        .style('fill', '#FF6600')
      .transition().duration(1000).delay(500).ease('elastic')
        .attr('x', c.width*0.2)
        .attr('y', c.height*0.8)

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

  d3.json 'twitterdata/users.json', (coll) ->
    #coll = coll.filter (u) -> u.coords
    coll = coll.map (u) ->
      u.geocoords = u.coords || [-3.22, 55.95]
      u.signed_up = new Date Date.parse(u.signed_up)
      u

    
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
      s = svg.selectAll('g.slide')
      if s[0].length > 0
        s.select('text')
            .transition().duration(500)
              .attr('x', -500)
            .remove()
        slides[currSlide]()
      else
        slides[currSlide]()
      currSlide++

    slides.push countDown
    slides.push slide("Hello")
    slides.push philSlide
    slides.push slide("d3.js")
    slides.push slide("Showreel")
    slides.push listUsers
    slides.push forceGraph
    slides.push circleTweetCount
    slides.push scaleTweetCount
    #push scaleTweetCountLog
    #slides.push addAxes
    slides.push scatterPlot
    slides.push addAxesAnnotations
    slides.push geoTweet
    slides.push explode
    slides.push slide("So like, wth?")
    #slides.push slide("So like, wth?")
    
    nextSlide()

    svg.on('click', nextSlide)
