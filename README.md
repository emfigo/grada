[![Build Status](https://api.travis-ci.org/emfigo/grada.png)](https://api.travis-ci.org/emfigo/grada)

GraDA
=====
GraDA is built for making easier the way you plot in ruby. GraDA is used mainly for data analysis.

#Installation

```ruby
gem install grada
```
---------
#### IMPORTANT:

##### 'GraDA' gem is deprecated.
--------

##### NOTE: Requires 'X11' to display the plots

In case you don't have X11

Ubuntu

```bash
sudo apt-get install gnuplot-x11
```
Mac

In case you don't have it, just install xQuartz

#Usage

When you use a `grada` object in your class, you get two basic methods:

```ruby
require 'grada'

class AtomicDevice
  ...
  radiation_levels_median_per_day = [0.001,0.01,1,10,1000]
  radiation_days = [0,1,2,3,4]
  grada = Grada::Graph.new(radiation_days, radiation_levels_median_per_day)
  ...
end

#Shows a default plot.
grada.display

#Saves the default plot into a file.
grada.save( filename: 'secret/radiation_levels/ffa/zonex/devicex/radiation_level_malaga', ext: 'svg' )
```

## Basic Usage

You can modify the default graph properties in whichever way you want:

```ruby
#For modifying the window width
grada.display( width: 1200 )

#For modifying the window height
grada.display( height: 1240 )

#For modifying the graph title
grada.display( title: 'Atomic Device X' )

#For modifying the horizontal label from the graph
grada.display( x_label: 'Day' )

#For modifying the vertical label from the graph
grada.display( y_label: 'smSv' )

#The type of graph you want. If you want the default you don't need to specify this parameter
#The options are:
# * :default
# * :histogram
# * :heatmap
grada.display( graph_type: :histogram )

#The type of line you want in the default graph. If you want a line you don't need to specify this parameter
#The options are:
# * 'lines'
# * 'points' (scatter plot)
# * 'linespoints'
grada.display( with: 'points' )

#You can combine them all
grada.display( title: 'Atomic Device X', x_label: 'Day', y_label: 'smSv', with: 'points' )

#You can add this options when saving a file
grada.save( filename: 'secret/radiation_levels/ffa/zonex/devicex/radiation_level_malaga', ext: 'png' ,title: 'Atomic Device X', x_label: 'Day', y_label: 'smSv', with: 'points' )
```

## Advance Usage

Also you can obtain more complex graphs. Here we will explain how to obtain most of them 

### MULTIPLE PLOTS IN ONE. 

```ruby
class AtomicDevice
  ...
  radiation_days = [0,1,2,3,4]
  radiation_levels_median_per_day = [{ malaga: [0.001,0.01,1,10,100], with: 'points', linewidth: '3' }, { granada: [1,10,100,100,1000] } ]
  grada = Grada::Graph.new(radiation_days, radiation_levels_median_per_day)
  ...
end
```

* Just show

```ruby
grada.display( title: 'Atomic Device X in 2 cities', x_label: 'Frequency', y_label: 'smSv/day_one' )
```

![Default graph](https://raw.github.com/emfigo/grada/master/assets/images/default_plot.png)

### HISTOGRAMS 

```ruby
class AtomicDevice
  ...
  radiation_levels_day_one = [0.001,0.01,1,0.001,0.001, 0.01, 0.01, 1, 0.01, 1, 0.01, 0.001, 0.001, 0.001, 0.001]
  grada = Grada::Graph.new(radiation_levels_day_one)
  ...
end
```

* Just show

```ruby
grada.display( graph_type: :histogram, title: 'Atomic Device X', x_label: 'Frequency', y_label: 'smSv/day_one' )
```

![Default graph](https://raw.github.com/emfigo/grada/master/assets/images/histogram.png)

* Save plot

```ruby
grada.save( filename: 'secret/radiation_levels/ffa/zonex/devicex/radiation_level_malaga', ext: 'png' ,graph_type: :histogram, title: 'Atomic Device X', x_label: 'Frequency', y_label: 'smSv/day_one' )
```
### HTML

##### NOTE: You need firefox or safari to display correctly the plots.

Create an html file is as simple as just saving the file with ext = 'html'. Grada will build a folder with the name that you have specified and inside of it will be the html file. Notice that GraDA builds it this way so it work, if you take out the html file from the folder, no graph will be displayed.

```ruby
grada.save( filename: 'secret/radiation_levels/ffa/zonex/devicex', ext: 'html' ,title: 'Atomic Device X in 2 cities', x_label: 'Frequency', y_label: 'smSv/day_one' )
```

![Default graph](https://raw.github.com/emfigo/grada/master/assets/images/default_plot_html.png)

```ruby
grada.save( filename: 'secret/radiation_levels/ffa/zonex/devicex/radiation_level_malaga', ext: 'html' ,graph_type: :histogram, title: 'Atomic Device X', x_label: 'Frequency', y_label: 'smSv/day_one' )
```

![Default graph](https://raw.github.com/emfigo/grada/master/assets/images/histogram_html.png)

### HEATMAPS.

##### NOTE: This type of plot can't be saved as an html.

```ruby
class AtomicDevice
  ...
  devices = { 0 => 'Device X', 1 => 'Device Y', 2 => 'Device Z' }
  radiation_difference_between_devices = [[0, 1000, 0.01],[1000, 0, 0.1],[0.01, 0.1, 0]]
  grada = Grada::Graph.new(radiation_difference_between_devices)
  ...
end
```

#### NOTE 2: It is important to specify the min and the max parameters, so you get a reasonable distribution of colors for the heatmap you want

* Just show

```ruby
grada.display( graph_type: :heatmap, title: 'Atomic Device Comparison', x_label: 'Difference', min: 0, max: 1)
```

![Default graph](https://raw.github.com/emfigo/grada/master/assets/images/heatmap.png)

* Save plot

```ruby
grada.save( filename: 'secret/radiation_levels/ffa/zonex/devicex/radiation_level_malaga', ext: 'png' ,graph_type: :heatmap, title: 'Atomic Device Comparison', x_label: 'Difference', min: 0, max: 1)
```

