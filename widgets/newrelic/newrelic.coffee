class Dashing.Newrelic extends Dashing.Widget
  @accessor 'current', Dashing.AnimatedValue

  ready: ->
    $node = $(@node)
    $container = $node.parent()
    $graph_height = (Dashing.widget_base_dimensions[1] * $container.data("sizey")) / 2 + 10
    $graph_width = (Dashing.widget_base_dimensions[0] * $container.data("sizex")) + (($container.data("sizex") - 1 ) * 10)
    @graph = new Rickshaw.Graph(
      element: document.querySelector("#" + this.id + " .newrelic-graph")
      renderer: 'area'
      height: $graph_height
      width: $graph_width
      series: [
        {
          color: document.getElementById(this.id).getAttribute('data-graph-color'),
          data: [{ x:0, y:0}]
        }
      ]
    )
    @graph.series[0].data = @get('points') if @get('points')
    @_createGraph @graph.series[0].data[@graph.series[0].data.length-1].y
    @graph.render()

  onData: (data) ->
    @_createGraph data.current

    if @graph
      @graph.series[0].data = data.points
      @graph.render()

    $(@node).fadeOut().fadeIn()

  _createGraph: (val) ->
    @responseGreen = document.getElementById(this.id).getAttribute('data-green')
    @responseYellow = document.getElementById(this.id).getAttribute('data-yellow')

    if (
      ((@responseGreen < @responseYellow) && (val <= @responseGreen)) ||
      ((@responseGreen > @responseYellow) && (val >= @responseGreen))
    )
      $('#' + this.id + '.widget-newrelic').css('background-color', '#073642')
      $('#' + this.id + '.widget-newrelic h1').css('color', '#2aa198')
      $('#' + this.id + '.widget-newrelic h2').css('color', '#859900')
      $('#' + this.id + '.widget-newrelic .updated-at').css('color', '#fff')
    else if (
      ((@responseGreen < @responseYellow) && ((val > @responseGreen) && (val <= @responseYellow))) ||
      ((@responseGreen > @responseYellow) && ((val < @responseGreen) && (val >= @responseYellow)))
    )
      $('#' + this.id + '.widget-newrelic').css('background-color', '#F1C40F')
      $('#' + this.id + '.widget-newrelic h1').css('color', '#000')
      $('#' + this.id + '.widget-newrelic h2').css('color', '#000')
      $('#' + this.id + '.widget-newrelic .updated-at').css('color', '#000')
    else
      $('#' + this.id + '.widget-newrelic').css('background-color', '#e74c3c')
      $('#' + this.id + '.widget-newrelic h1').css('color', '#fff')
      $('#' + this.id + '.widget-newrelic h2').css('color', '#fff')
      $('#' + this.id + '.widget-newrelic .updated-at').css('color', '#fff')
