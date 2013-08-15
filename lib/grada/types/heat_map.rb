module Grada
  class HeatMap
    def self.plot(x, opts, &block)
      Gnuplot.open do
        Gnuplot::Plot.construct do |plot|
          block.call plot if block
          
          plot.set "pm3d map"
          plot.set "palette color"
          plot.set "xrange [0:#{x.size-1}]"
          plot.set "yrange [0:#{x.size-1}]"
          plot.set "cbrange [#{opts[:min]}:#{opts[:max]}]"
          plot.set "cblabel \"#{opts[:x_label]}\""
          plot.set "palette model RGB"
          plot.set "palette define"
         
          plot.title opts[:title]
          plot.data << Gnuplot::DataSet.new(Matrix.columns(x)) do |ds|
            ds.with = opts[:with] 
          end
        end
      end
    end
  end
end
