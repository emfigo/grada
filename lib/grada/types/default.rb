module Grada
  #All styles you can specify for the plots
  #
  STYLES = [:linestyle, :linetype, :linewidth, :linecolor, :pointtype, :pointsize, :fill]
   
  class Default
    def self.plot(x, y, opts, &block)
      Gnuplot.open do
        Gnuplot::Plot.construct do |plot|
          block.call plot if block
    
          plot.title opts[:title]
          
          plot.xlabel opts[:x_label]
          plot.ylabel opts[:y_label]
    
          if multiple_data?(y)
            y.each_with_index do |dic, index|
              dic.each do |k, v|
                if ! Grada::STYLES.include?(k.to_sym) && k.to_sym != :with
                  raise NoPlotDataError if ! v.nil? && x.size != v.size
              
                  style = Gnuplot::Style.new do |ds|
                    ds.index = index
                    Grada::STYLES.each do |style|
                      ds.send("#{style}=", dic[style]) if dic[style]
                    end
                  end.to_s
  
                  plot.data << Gnuplot::DataSet.new([x,v]) do |ds|
                    ds.with = dic[:with] || opts[:with]
                    ds.with += style
                    ds.title = "#{k}"
                  end
                end
              end
            end
          else
            raise NoPlotDataError if ! y.nil? && x.size != y.size
            
            plot.data << Gnuplot::DataSet.new([x,y]) do |ds|
              ds.with = opts[:with] 
            end
          end
        end
      end
    end
    
    private

    def self.multiple_data?(l)
      if l.is_a?(Array)
        l.each do |elem|
          return false if !  elem.is_a?(Hash)
        end
    
        return true
      end
      
      false
    end
  end
end
