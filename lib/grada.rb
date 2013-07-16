require 'grada/gnuplot'

class Grada
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

  #All styles you can specify for the plots
  #
  STYLES = [:linestyle, :linetype, :linewidth, :linecolor, :pointtype, :pointsize, :fill]
 
  #Graph offsets
  #
  LEFT   =  0.25
  RIGHT  =  0.25
  TOP    =  0.25
  BOTTOM =  0.25
  
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
  
  # Displays a graph in a window. 
  # You can specify all the options that you need:
  # *width* (Integer)
  # *height* (Integer)
  # *title* (Integer)
  # *x_label* (String)
  # *y_label* (String)
  # *graph_type* (:histogram, :heatmap) default: :default
  # *with* ('points', 'linespoints') default: 'lines'
  #
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
      
      plot_histogram do |plot|
        plot.set "terminal x11 size #{@opts[:width]},#{@opts[:height]}"
        plot.set "offset graph #{LEFT},#{RIGHT},#{TOP},#{BOTTOM}"
      end
    elsif @opts[:graph_type] == :heatmap
      Matrix.columns(@x) rescue raise NoPlotDataError
      @opts[:with] = 'image'
      
      plot_heat_map do |plot|
        plot.set "offset graph #{LEFT},#{RIGHT},#{TOP},#{BOTTOM}"
      end
    else
      raise NoPlotDataError if @y.nil?
      
      plot_and do |plot|
        plot.set "terminal x11 size #{@opts[:width]},#{@opts[:height]}"
        plot.set "offset graph #{LEFT},#{RIGHT},#{TOP},#{BOTTOM}"
      end
    end
  end
  
  # Save the graph in a png file. 
  # You can specify all the options that you need as _display_ but also need to specify the file
  #
  # Example:
  #   >> grada.save({ filename: 'secret/radiation_levels/ffa/zonex/devicex/radiation_level_malaga.png' ,title: 'Atomic Device X', x_label: 'Day', y_label: 'smSv', with: 'points' }) 
  #   => ""
  # Arguments:
  #   opts: (Hash) *optional*
  
  def save(opts = {})
    @opts = DEFAULT_OPTIONS.merge(opts)
    
    return nil if @opts[:filename].nil?
    
    if @opts[:graph_type] == :histogram
      population_data?(@x)
      
      plot_histogram do |plot|
        plot.output @opts[:filename]
        plot.set "terminal png size #{@opts[:width]}, #{@opts[:height]} crop"
        plot.terminal 'png'
        plot.set "offset graph #{LEFT},#{RIGHT},#{TOP},#{BOTTOM}"
      end
    elsif @opts[:graph_type] == :heatmap
      Matrix.columns(@x) rescue raise NoPlotDataError
      @opts[:with] = 'image'
      
      plot_heat_map do |plot|
        plot.output @opts[:filename]
        plot.set "terminal png size #{@opts[:width]}, #{@opts[:height]} crop"
        plot.terminal 'png'
        plot.set "offset graph #{LEFT},#{RIGHT},#{TOP},#{BOTTOM}"
      end
    else
      raise NoPlotDataError if @y.nil?
      
      plot_and do |plot|
        plot.output @opts[:filename]
        plot.set "terminal png size #{@opts[:width]}, #{@opts[:height]} crop"
        plot.terminal 'png'
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
  
  def multiple_data?(l)
    if l.is_a?(Array)
      l.each do |elem|
        return false if !  elem.is_a?(Hash)
      end
  
      return true
    end
    
    false
  end
  
  def plot_and(&block)
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        block[plot] if block
  
        plot.title @opts[:title]
        
        plot.xlabel @opts[:x_label]
        plot.ylabel @opts[:y_label]
  
        if multiple_data?(@y)
          @y.each_with_index do |dic, index|
            dic.each do |k, v|
              if ! STYLES.include?(k.to_sym) && k.to_sym != :with
                raise NoPlotDataError if ! v.nil? && @x.size != v.size
            
                style = Gnuplot::Style.new do |ds|
                  ds.index = index
                  STYLES.each do |style|
                    ds.send("#{style}=", dic[style]) if dic[style]
                  end
                end.to_s

                plot.data << Gnuplot::DataSet.new([@x,v]) do |ds|
                  ds.with = dic[:with] || @opts[:with]
                  ds.with += style
                  ds.title = "#{k}"
                end
              end
            end
          end
        else
          raise NoPlotDataError if ! @y.nil? && @x.size != @y.size
          
          style = Gnuplot::Style.new do |ds|
            ds.index = index
            STYLES.each do |style|
              ds.send("#{style}=", dic[style]) if dic[style]
            end
          end.to_s
          
          plot.data << Gnuplot::DataSet.new([@x,@y]) do |ds|
            ds.with = @opts[:with] 
            ds.with += style
          end
        end
      end
    end
  end
  
  def plot_histogram(&block)
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        block[plot] if block
        
        width = ( @x.max - @x.min ) / @x.size
  
        plot.title @opts[:title]
        
        plot.set "style data histogram"
        plot.xlabel @opts[:x_label]
        plot.ylabel "Frequency"
        plot.set "style fill solid 0.5"
        plot.set "xrange [#{@x.min}:#{@x.max}]"
        plot.set "boxwidth #{ width * 0.4}"
        plot.set "xtics #{@x.min},#{(@x.max-@x.min)/5},#{@x.max}"
        plot.set "tics out nomirror"

        style = Gnuplot::Style.new do |ds|
          ds.index = index
          STYLES.each do |style|
            ds.send("#{style}=", dic[style]) if dic[style]
          end
        end.to_s
          
        plot.data << Gnuplot::DataSet.new(@x) do |ds|
          ds.with = 'boxes'
          ds.with += style
          ds.title = @opts[:x_label]
          ds.using = '($1):(1.0)'
          ds.smooth = 'freq'
        end
      end
    end
  end
  
  def plot_heat_map(&block)
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        block[plot] if block
        
        plot.set "pm3d map"
        plot.set "palette color"
        plot.set "xrange [0:#{@x.size-1}]"
        plot.set "yrange [0:#{@x.size-1}]"
        plot.set "cbrange [#{@opts[:min]}:#{@opts[:max]}]"
        plot.set "cblabel \"#{@opts[:x_label]}\""
        plot.set "palette model RGB"
        plot.set "palette define"
       
        plot.title @opts[:title]
        plot.data << Gnuplot::DataSet.new(Matrix.columns(@x)) do |ds|
          ds.with = @opts[:with] 
        end
      end
    end
  end
end
