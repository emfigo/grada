require 'grada/types/gnuplot'
require 'grada/types/histogram'
require 'grada/types/default'
require 'grada/types/heat_map'

module Grada
  class Graph
    # Not valid the format of the object to construct the graph
    #
    class NotValidArrayError < RuntimeError; end
    
    # Not valid the content of the array you're passing to build the graph
    #
    class NotValidDataError < RuntimeError; end
    
    # Can't build the plot
    #
    class NoPlotDataError < RuntimeError; end
    
    attr_reader :x
    attr_reader :y
    
    DEFAULT_OPTIONS = {width: 1920,
                       height: 1080,
                       title: "Graph",
                       x_label: "X",
                       y_label: "Y",
                       with: 'lines',
                       graph_type: :default}
  
    #Graph offsets
    #
    LEFT   =  0.05
    RIGHT  =  0.05
    TOP    =  0.05
    BOTTOM =  0.05
    
    # Hello GraDA
    #
    
    def self.hi
      puts "Hello GraDA"
    end
      
    # Initialize object with the data you want to plot. 
    # It can vary depending on the type of graph.
    # The second argument is optional.
    #
    # Example:
    #   >> radiation_levels_median_per_day = [0.001,0.01,1,10,1000]
    #   >> radiation_days = [0,1,2,3,4]
    #   >> grada = Grada.new(radiation_days, radiation_levels_median_per_day)
    #   => #<Grada:0x007f962a8dc9b8 @x=[0, 1, 2, 3, 4], @y=[0.001, 0.01, 1, 10, 1000]>
    # Arguments:
    #   x: (Array)
    #   y: (Array) *optional*
    
    def initialize(x, y = nil)
      @x = validate(x)
      @y = y.nil? ? y : validate(y)  
    end
    
    # Displays a graph in a X11 window. 
    # You can specify all the options that you need:
    # *width* (Integer)
    # *height* (Integer)
    # *title* (Integer)
    # *x_label* (String)
    # *y_label* (String)
    # *graph_type* (:histogram, :heatmap) default: :default
    # *with* ('points', 'linespoints') default: 'lines'
    #
    # Also is important to know that you can interact with the graph:
    # * Zoom in                 =>  right click and drag the mouse to cover the area you want 
    #                               or 
    #                               use the scroll wheel
    # 
    # * Zoom out                =>  press key 'a'
    #                               or
    #                               if you want to go back to a previous state of zoom press key 'p'
    #
    #  * Exit interactive mode  =>  press key 'q'
    #                               or
    #                               just close the window
    #
    #  * Save image             =>  working on it 
    #
    # Example:
    #   >> grada.display
    #   => ""
    #   >> grada.display({ title: 'Atomic Device X', x_label: 'Day', y_label: 'smSv', with: 'points' })
    #   => ""
    # Arguments:
    #   opts: (Hash) *optional*
    
    def display(opts = {})
      @opts = DEFAULT_OPTIONS.merge(opts)
      
      if @opts[:graph_type] == :histogram
        population_data?(@x)
        return nil if @x.empty?
        
        Histogram.plot(@x, @opts) do |plot|
          plot.set "terminal x11 size #{@opts[:width]},#{@opts[:height]}"
          plot.set "offset graph #{LEFT},#{RIGHT},#{TOP},#{BOTTOM}"
        end
      elsif @opts[:graph_type] == :heatmap
        Matrix.columns(@x) rescue raise NoPlotDataError
        @opts[:with] = 'image'
        
        HeatMap.plot(@x, @opts) do |plot|
          plot.set "terminal x11 size #{@opts[:width]},#{@opts[:height]}"
          plot.set "offset graph #{LEFT},#{RIGHT},#{TOP},#{BOTTOM}"
        end
      else
        raise NoPlotDataError if @y.nil?
        
        Default.plot(@x, @y, @opts) do |plot|
          plot.set "terminal x11 size #{@opts[:width]},#{@opts[:height]}"
          plot.set "offset graph #{LEFT},#{RIGHT},#{TOP},#{BOTTOM}"
        end
      end
    end
    
    # Save the graph in a png file. 
    # You can specify all the options that you need as _display_ but also need to specify the file root-name and extension.
    # The possible extensions you can use for saving a file are:
    #  *png*
    #  *gif*
    #  *jpeg*
    #  *html*           (not valid for heatmaps)
    #  *svg* => default (not valid for heatmaps)
    #
    # Example:
    #   >> grada.save({ filename: 'secret/radiation_levels/ffa/zonex/devicex/radiation_level_malaga', ext: 'png' ,title: 'Atomic Device X', x_label: 'Day', y_label: 'smSv', with: 'points' }) 
    #   => ""
    # Arguments:
    #   opts: (Hash) *optional*
    
    def save(opts = {})
      @opts = DEFAULT_OPTIONS.merge(opts)
      
      return nil if @opts[:filename].nil?
  
      ext = @opts[:ext] || 'svg'
      
      if @opts[:graph_type] == :histogram
        population_data?(@x)
        return nil if @x.empty?
       
        return Histogram.plot_html(@x, @opts) if ext == 'html'

        Histogram.plot(@x, @opts) do |plot|
          plot.output "#{@opts[:filename]}.#{ext}" 
          plot.set "terminal #{ext} size #{@opts[:width]}, #{@opts[:height]} crop"
          plot.set "offset graph #{LEFT},#{RIGHT},#{TOP},#{BOTTOM}"
        end
      elsif @opts[:graph_type] == :heatmap
        Matrix.columns(@x) rescue raise NoPlotDataError
        @opts[:with] = 'image'

        ext = 'png' if ext == 'html' || ext == 'svg'
        
        HeatMap.plot(@x, @opts) do |plot|
          plot.output "#{@opts[:filename]}.#{ext}" 
          plot.set "terminal #{ext} size #{@opts[:width]}, #{@opts[:height]} crop"
        end
      else
        raise NoPlotDataError if @y.nil?
 
        return Default.plot_html(@x, @y, @opts) if ext == 'html' 

        Default.plot(@x, @y, @opts) do |plot|
          plot.output "#{@opts[:filename]}.#{ext}" 
          plot.set "terminal #{ext} size #{@opts[:width]}, #{@opts[:height]} crop"
          plot.set "offset graph #{LEFT},#{RIGHT},#{TOP},#{BOTTOM}"
        end
      end
    end
    
    private
    
    def validate(l)
      raise NotValidArrayError if ! l.is_a?(Array)
    
      l.each do |elem|
        raise NotValidDataError if ! ( elem.is_a?(Float) || elem.is_a?(Integer) || elem.is_a?(Array) || elem.is_a?(Hash))
      end
    end
    
    def population_data?(l)
      raise NotValidArrayError if ! l.is_a?(Array)
    
      l.each do |elem|
        raise NotValidDataError if ! ( elem.is_a?(Float) || elem.is_a?(Integer))
      end
    end
  end
end
