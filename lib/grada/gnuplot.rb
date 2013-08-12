require 'matrix'
require 'open3'

class NoGnuPlotExecutableFound < RuntimeError; end 

class Gnuplot
  def self.candidate?(candidate)
    return candidate if File::executable? candidate

    ENV['PATH'].split(File::PATH_SEPARATOR).each do |dir|
      possible_candidate = File::join dir, candidate.strip

      return possible_candidate if File::executable? possible_candidate
    end

    nil
  end
  
  def self.find_exec(bin)
    bin_list = RUBY_PLATFORM =~ /mswin|mingw/ ? [bin, "#{bin}.exe"] : [bin]

    bin_list.each do |c|
      exec = candidate?(c)
      return exec if exec
    end

    nil
  end
  
  def self.gnuplot
    gnu_exec = find_exec( ENV['RB_GNUPLOT'] || 'gnuplot' )
    raise NoGnuPlotExecutableFound unless gnu_exec
    gnu_exec
  end

  def self.open(persist = true, &block)
    gnuplot_cmd = gnuplot

    commands = yield

    output = StringIO.new
    Open3::popen3(gnuplot_cmd, '-persist') do |data_in, data_out, stderr, wait_th|
      data_in << commands[:plot_settings]
      data_in << commands[:plot_data]

      data_in.flush
      sleep 1
      
      while true do
        window = IO::popen('xprop -name "Gnuplot" WM_NAME 2>/dev/null').gets
        break unless window
        sleep 1
      end
    end
    
    output.string
  end
end

class Gnuplot::Plot
  attr_accessor :cmd, :data, :settings, :styles, :arbitrary_lines

  QUOTED_METHODS = [ "title", "output", "xlabel", "x2label", "ylabel", "y2label", "clabel", "cblabel", "zlabel" ]

  def initialize
    @settings = []
    @arbitrary_lines = []
    @data = []
    @styles = []
  end

  def self.construct(&block)
    plot = new
    
    block.call plot if block_given?
    
    { plot_settings: plot.to_gplot, plot_data:  plot.store_datasets }
  end

  def method_missing(meth, *args)
    set meth.id2name, *args
  end

  def set ( var, value = "" )
    value = "\"#{value}\"" if QUOTED_METHODS.include? var unless value =~ /^'.*'$/
    @settings << [ :set, var, value ]
  end

  def unset (var)
    @settings << [ :unset, var ]
  end

  def to_gplot(io = '')
    @settings.each { |setting| io += setting.map(&:to_s).join(' ') + "\n" }
    @styles.each{ |style| io += style.to_s + "\n" }
    @arbitrary_lines.each{ |line| io += line + "\n" }

    io
  end

  def store_datasets(io = '')
    if @data.size > 0
      io +=  'plot' + " #{ @data.map { |element| element.plot_args }.join(', ') } \n" 
      io += @data.map { |ds| ds.to_gplot }.compact.join("\n") + "\n"
    end
    
    io
  end
end

class Gnuplot::Style
  attr_accessor :linestyle, :linetype, :linewidth, :linecolor, :pointtype, :pointsize, :fill, :index

  alias :ls :linestyle 
  alias :lt :linetype
  alias :lw :linewidth
  alias :lc :linecolor
  alias :pt :pointtype
  alias :ps :pointsize
  alias :fs :fill

  alias :ls= :linestyle= 
  alias :lt= :linetype=
  alias :lw= :linewidth=
  alias :lc= :linecolor=
  alias :pt= :pointtype=
  alias :ps= :pointsize=
  alias :fs= :fill=
  
  STYLES = [:ls, :lt, :lw, :lc, :pt, :ps, :fs]

 def self.increment_index
   @index ||= 0
   @index += 1
 end

 def initialize
   STYLES.each do |style|
     send("#{style}=", nil)
   end

   yield self if block_given?

 end

 def to_s
   str = ' '

   STYLES.each do |style|
     str += " #{style} #{send(style)}" if send(style) 
   end

   str == ' ' ? '' : str
 end
end

class Gnuplot::DataSet
  attr_accessor :title, :with, :using, :data, :linewidth, :linecolor, :matrix, :smooth, :axes, :index, :linestyle

  alias :ls :linestyle

  def initialize(data = nil)
    @data = data
    @linestyle = nil
    @title = nil
    @with = nil
    @using = nil
    @linewidth = nil
    @linecolor = nil 
    @matrix = nil
    @smooth = nil
    @axes = nil
    @index = nil

    yield self if block_given?
  end

  def notitle
    '"No Title"'
  end

  def plot_args(io = '')
    io += @data.is_a?(String) ? @data : "'-'"
    #io += " index #{@index}" if @index
    io += " using #{@using}" if @using
    io += " axes #{@axes}" if @axes
    io += " title #{@title ? "\"#{@title}\"" : notitle}"
    io += " matrix #{@matrix}" if @matrix
    io += " smooth  #{@smooth}" if @smooth
    io += " with #{@with}" if @with
    io += " linecolor #{@linecolor}" if @linecolor
    io += " line #{@index} linewidth #{@linewidth}" if @linewidth
    io += " linestyle #{@linestyle.index}" if @linestyle
    
    io
  end

  def to_gplot
    return nil if @data.nil? || @data.is_a?(String)

    @data.to_gplot
  end
end

class Array
  def to_gplot
    if number_series?(self)
      series_for_plot = ''
      self.each { |elem| series_for_plot += "#{elem}\n" }
      series_for_plot + 'e'
    else
      self[0].zip(self[1]).map{ |elem| elem.join(' ') }.join("\n") + "\ne\n"
    end
  end
  
  private 
  
  def number_series?(data)
    data.each do |elem|
      return false unless elem.is_a?(Numeric)
    end

    true
  end
end

class Matrix
  def to_gplot
    matrix_for_plot = ''

    (0...self.column_size).each do |j|
      (0...self.row_size).each do |i|
        matrix_for_plot += "#{i} #{j} #{self[j,i]}\n" if self[j,i]
      end
    end

    matrix_for_plot
  end
end
