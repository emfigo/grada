$(function() {
  $.getJSON(".grada_histogram.json", function(data){ 
    var min_x = 0.0
    var max_x = 0.0
    var min_y = 0.0
    var max_y = 0.0
    
    var plotdata = $.map(data, function(graph, index) {
      return {
        data: $.map(graph.data, function(point, index) {
                x = point.x;
                y = point.y;

                if (x < min_x){
                  min_x = x;
                }
                if (x > max_x){
                  max_x = x
                }

                if (y < min_y){
                  min_y = y;
                }
                if (y > max_y){
                  max_y = y
                }
                return [[x, y]];
              })
      };
    });
      
    var options = {
      series: {
        lines:  { show: false },
        points: { show: false },
        bars:   { show: true,
                  align: "center",
                  barWidth: 0.03
                }
      },
      selection: { mode: "xy" }
    };
    
    var placeholder = $("#grada_graph");

    placeholder.bind("plotselected", function (event, ranges) {
      plot = $.plot(
        placeholder,
        plotdata,
        $.extend(true, {}, options, 
          { xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to },
            yaxis: { min: ranges.yaxis.from, max: ranges.yaxis.to } }));
    });

    var plot = $.plot(placeholder, plotdata, options);
    
    $('#reset').click(function() {
      plot = $.plot(placeholder, plotdata, options);
    });
  });

  $.getJSON(".grada_default.json", function(data){
    var min_x = 0.0
    var max_x = 0.0
    var min_y = 0.0
    var max_y = 0.0

    var plotdata = $.map(data, function(graph, index) {
      return {
        data: $.map(graph.data, function(point, index) {
                x = point.x;
                y = point.y;
                show_lines = true;
                show_points = false;
                if(graph.style == 'points'){
                  show_lines = false;
                  show_points = true;
                }else if(graph.style == 'linespoints'){
                  show_points = true;
                }

                if (x < min_x){
                  min_x = x;
                }
                if (x > max_x){
                  max_x = x
                }

                if (y < min_y){
                  min_y = y;
                }
                if (y > max_y){
                  max_y = y
                }
                return [[point.x, point.y]];
              }),
        label: graph.label,
        lines:  { show: show_lines },
        points: { show: show_points, symbol: "cross"}
      };
    });
    
    var options = {
      xaxis: { min: min_x, max: max_x },
      yaxis: { min: min_y, max: max_y },
      selection: { mode: "xy" }
    };
    
    var placeholder = $("#grada_graph");

    placeholder.bind("plotselected", function (event, ranges) {
      plot = $.plot(
        placeholder,
        plotdata,
        $.extend(true, {}, options, 
          { xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to },
            yaxis: { min: ranges.yaxis.from, max: ranges.yaxis.to } }));
    });

    var plot = $.plot(placeholder, plotdata, options);
    
    $('#reset').click(function() {
      plot = $.plot(placeholder, plotdata, options);
    });
  });
});

