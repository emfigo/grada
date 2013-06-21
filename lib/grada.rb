require 'gnuplot'

class Grada
  attr_reader :x
  attr_reader :y

  DEFAULT_OPTIONS = {width: 1600,
                     height: 400,
                     title: "Graph",
                     x_label: "Time",
                     y_label: "Y",
                     with: 'lines',
                     graph_type: :default}
  
  
  def self.hi
    puts "Hello GraDA"
  end
  
  def initialize(x, y = nil)
    @x = x
    @y = y 
  end
  
  def display(opts = {})
    @opts = DEFAULT_OPTIONS.merge(opts)
    
    if @opts[:graph_type] == :histogram
      plot_histogram do |plot|
        plot.set "terminal x11 size #{@opts[:width]},#{@opts[:height]}"
      end
    elsif @opts[:graph_type] == :heatmap
      @opts[:with] = 'image'
      plot_heat_map do |plot|
      end
    else
      if ! @y.nil?
        plot_and do |plot|
          plot.set "terminal x11 size #{@opts[:width]},#{@opts[:height]}"
        end
      end
    end
  end

  def save(opts = {})
    @opts = DEFAULT_OPTIONS.merge(opts)
    
    return nil if @opts[:filename].nil?
    
    if @opts[:graph_type] == :histogram
      plot_histogram do |plot|
        plot.output @opts[:filename]
        plot.set "terminal x11 size #{@opts[:width]},#{@opts[:height]}"
        plot.terminal 'png'
      end
    elsif @opts[:graph_type] == :heatmap
      @opts[:with] = 'image'
      plot_heat_map do |plot|
        plot.output @opts[:filename]
        plot.terminal 'png'
      end
    else
      if ! @y.nil?
        plot_and do |plot|
          plot.output @opts[:filename]
          plot.set "terminal x11 size #{@opts[:width]*10},#{@opts[:height]}"
          plot.terminal 'png'
        end
      end
    end
  end
  
  private
 
  def plot_and(&block)
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        block[plot]

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
        block[plot]

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
        block[plot]
        
        plot.set "pm3d map"
        plot.set "palette color"
        plot.set "xrange [0:#{@x.size-1}]"
        plot.set "yrange [0:#{@x.size-1}]"
        plot.set "cbrange [#{@opts[:min]}:#{@opts[:max]}]"
        plot.set "cblabel \"#{@opts[:x_label]}\""
        plot.set "palette model RGB"
        plot.set "palette define"
       
        plot.title @opts[:title]
        plot.data = [Gnuplot::DataSet.new(Matrix.columns(@x).transpose) do |ds|
          ds.with = @opts[:with] 
        end]
      end
    end
  end
end
