require 'json'

module Grada
  #All styles you can specify for the plots
  #
  STYLES = [:linestyle, :linetype, :linewidth, :linecolor, :pointtype, :pointsize, :fill]
 
  class DefaultBase
    
    protected 
    
    JQUERY_JS = 'https://rawgithub.com/emfigo/flot/master/jquery.js'
    FLOT_EXCANVAS_JS = 'https://rawgithub.com/emfigo/flot/master/excanvas.min.js'
    FLOT_JS = 'https://rawgithub.com/emfigo/flot/master/jquery.flot.js'
    FLOT_SELECTION_JS = 'https://rawgithub.com/emfigo/flot/master/jquery.flot.selection.js'
    FLOT_SYMBOL_JS = 'https://rawgithub.com/emfigo/flot/master/jquery.flot.symbol.js'
    FLOT_THRESHOLD_JS = 'https://rawgithub.com/emfigo/flot/master/jquery.flot.threshold.js'
    GRADA_JS = 'https://rawgithub.com/emfigo/grada/master/assets/javascripts/grada.js'

    TITLE_CSS = 'https://rawgithub.com/emfigo/grada/master/assets/stylesheets/grada_title.css'
    BODY_CSS = 'https://rawgithub.com/emfigo/grada/master/assets/stylesheets/grada_body.css'
    
    def self.multiple_data?(l)
      if l.is_a?(Array)
        l.each do |elem|
          return false if !  elem.is_a?(Hash)
        end
    
        return true
      end
      
      false
    end
   
    def self.create_html_dir(path)
      path.split("/").tap do |dirs| 
        last_dir = dirs.pop
        
        dirs << "#{last_dir}_grada_html"
        FileUtils.mkdir_p(dirs.join("/"))
        dirs << last_dir 
      end.join('/')
    end

    def self.create_grada_json(opts, x, y = nil)
      filename = opts[:filename].split("/").tap do |file|
        hidden_file = file.pop

        file << ".grada_#{opts[:graph_type]}"
      end.join("/")


      File.open("#{filename}.json",'w') do |f|
        f << generate_grada_json(opts, x, y)
      end
    end

    def self.html_head
      "<head>
        <script src='#{JQUERY_JS}' type='text/javascript'></script>
        <script src='#{FLOT_EXCANVAS_JS}' type='text/javascript'></script>
        <script src='#{FLOT_JS}' type='text/javascript'></script>
        <script src='#{FLOT_SELECTION_JS}' type='text/javascript'></script>
        <script src='#{FLOT_SYMBOL_JS}' type='text/javascript'></script>
        <script src='#{FLOT_THRESHOLD_JS}' type='text/javascript'></script>
        <script src='#{GRADA_JS}' type='text/javascript'></script>
        
        <link href='#{TITLE_CSS}' rel='stylesheet' type='text/css' />
        <link href='#{BODY_CSS}' rel='stylesheet' type='text/css' />
      </head>\n"
    end
    
    def self.html_title(title)
      "    <div class='grada_title'>  
              <h2>#{title}</h2>
           </div>\n"
    end
    
    def self.html_graph
      "    <div class='grada_body'>  
              <div id='grada_graph'></div>
           </div>\n"
    end

    def self.html_panel
      "    <div class='grada_panel'>
              <span id='reset'>Reset Zoom</span>
           </div>\n"
    end

    private

    def self.compose_grada_json_data(x, y)
      if y.nil?
        x.sort.group_by{ |elem| elem }.map{ |k,v| { x: k, y: v.size } }
      else
        x.zip(y).map do |comp|
          { x: comp.first, y: comp.last }
        end
      end
    end
    
    def self.generate_grada_json(opts, x, y = nil)
      json = []

      if multiple_data?(y)
        y.each do |dic|
          dic.each do |k, v|
            if ! Grada::STYLES.include?(k.to_sym) && k.to_sym != :with
              raise Grada::Graph::NoPlotDataError if ! v.nil? && x.size != v.size

              json << { data: compose_grada_json_data(x, v), label: "#{k}", style: dic[:with] || opts[:with] }
            end
          end
        end
      else
        json << { data: compose_grada_json_data(x, y), label: opts[:title], style: opts[:with] }
      end

      JSON.pretty_generate(json)
    end
  end
end
