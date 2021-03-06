module Grada
  class Histogram < DefaultBase
    def self.plot(x, opts, &block)
      Gnuplot.open do
        Gnuplot::Plot.construct do |plot|
          block.call plot if block 
          
          width = ( x.max - x.min ) / x.size
    
          plot.title opts[:title]
          
          plot.set "style data histogram"
          plot.xlabel opts[:x_label]
          plot.ylabel "Frequency"
          plot.set "style fill solid 0.5"
          plot.set "xrange [#{x.min}:#{x.max}]"
          plot.set "boxwidth #{ width * 0.1}"
          plot.set "xtics #{x.min},#{(x.max-x.min)/5},#{x.max}"
          plot.set "tics out nomirror"
  
          plot.data << Gnuplot::DataSet.new(x) do |ds|
            ds.with = 'boxes'
            ds.title = opts[:x_label]
            ds.using = '($1):(1.0)'
            ds.smooth = 'freq'
          end
        end
      end 
    end
    
    def self.plot_html(x, opts)
      opts[:filename] = create_html_dir(opts[:filename])

      create_grada_json(opts, x)

      File.open("#{opts[:filename]}.html",'w') do |f|
        f << html_head
        f << "<body>\n"
        f << "  <div class=grada_main>\n"
        f << html_title(opts[:title])
        f << html_graph
        f << html_panel
        f << "  </div>"
        f << "</body>"
      end
    end 
  end
end
