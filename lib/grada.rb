require 'gnuplot'

class Grada
  class NotValidArrayError < RuntimeError; end
  class NotValidDataError < RuntimeError; end
  class NoPlotDataError < RuntimeError; end

  attr_reader :x
  attr_reader :y

  DEFAULT_OPTIONS = {width: 1600,
                     height: 400,
                     title: "Graph",
                     x_label: "X",
                     y_label: "Y",
                     with: 'lines',
                     graph_type: :default}
  
  
  def self.hi
    puts "Hello GraDA"
  end
  
  def initialize(x, y = nil)
    raise NoPlotDataError if ! y.nil? && x.size != y.size

    @x = validate(x)
    @y = y.nil? ? y : validate(y)  
  end
  
  def display(opts = {})
    @opts = DEFAULT_OPTIONS.merge(opts)
    
    if @opts[:graph_type] == :histogram
      population_data?(@x)
      
      plot_histogram do |plot|
        plot.set "terminal x11 size #{@opts[:width]},#{@opts[:height]}"
      end
    elsif @opts[:graph_type] == :heatmap
      Matrix.columns(@x) rescue raise NoPlotDataError
      @opts[:with] = 'image'
      
      plot_heat_map
    else
      raise NoPlotDataError if @y.nil?
      
      plot_and do |plot|
        plot.set "terminal x11 size #{@opts[:width]},#{@opts[:height]}"
      end
    end
  end

  def save(opts = {})
    @opts = DEFAULT_OPTIONS.merge(opts)
    
    return nil if @opts[:filename].nil?
    
    if @opts[:graph_type] == :histogram
      population_data?(@x)
      
      plot_histogram do |plot|
        plot.output @opts[:filename]
        plot.set "terminal x11 size #{@opts[:width]},#{@opts[:height]}"
        plot.terminal 'png'
      end
    elsif @opts[:graph_type] == :heatmap
      Matrix.columns(@x) rescue raise NoPlotDataError
      @opts[:with] = 'image'
      
      plot_heat_map do |plot|
        plot.output @opts[:filename]
        plot.terminal 'png'
      end
    else
      raise NoPlotDataError if @y.nil?
      
      plot_and do |plot|
        plot.output @opts[:filename]
        plot.set "terminal x11 size #{@opts[:width]*10},#{@opts[:height]}"
        plot.terminal 'png'
      end
    end
  end
  
  private
  
  def validate(l)
    raise NotValidArrayError if ! l.is_a?(Array)

    l.each do |elem|
      raise NotValidDataError if ! ( elem.is_a?(Float) || elem.is_a?(Integer) || elem.is_a?(Array))
    end
  end
  
  def population_data?(l)
    raise NotValidArrayError if ! l.is_a?(Array)

    l.each do |elem|
      raise NotValidDataError if ! ( elem.is_a?(Float) || elem.is_a?(Integer))
    end
  end
  
  def plot_and(&block)
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        block[plot] if block

        plot.title @opts[:title]
        
        plot.xlabel @opts[:x_label]
        plot.ylabel @opts[:y_label]

        plot.data << Gnuplot::DataSet.new([@x,@y]) do |ds|
          ds.with = @opts[:with] 
        end
      end
    end
  end
  
  def plot_histogram(&block)
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        block[plot] if block

        plot.title @opts[:title]
        
        plot.set "style data histogram"
        plot.xlabel @opts[:x_label]
        plot.ylabel "Frecuency"

        x = @x.sort.group_by { |xi| xi }.map{|k,v| v.count }
        
        plot.data << Gnuplot::DataSet.new(x) do |ds|
          ds.with = @opts[:with] 
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
        plot.data = [Gnuplot::DataSet.new(Matrix.columns(@x)) do |ds|
          ds.with = @opts[:with] 
        end]
      end
    end
  end
end
