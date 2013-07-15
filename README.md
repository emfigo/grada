GraDA
=====
Graphic Data Analysis Gem

Note: requires `X11` to display the plots

GraDA lets you graph data so you can analyze it. This gem was created for data investigation purposes.

## Gem Summary

When you use a `grada` object in your class, you get two basic methods:

```ruby
require 'grada'

class AtomicDevice
  ...
  radiation_levels_median_per_day = [0.001,0.01,1,10,1000]
  radiation_days = [0,1,2,3,4]
  grada = Grada.new(radiation_days, radiation_levels_median_per_day)
  ...
end

#Shows a default plot.
grada.display

#Saves the default plot into a file.
grada.save( filename: 'secret/radiation_levels/ffa/zonex/devicex/radiation_level_malaga.png' )
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
grada.save({ filename: 'secret/radiation_levels/ffa/zonex/devicex/radiation_level_malaga.png' ,title: 'Atomic Device X', x_label: 'Day', y_label: 'smSv', with: 'points' })
```

## Advance Usage

Also you can obtain more complex graphs. Here we will explain how to obtain most of them 

### In order to create a default plot with multiple graphs. 

```ruby
class AtomicDevice
  ...
  radiation_days = [0,1,2,3,4]
  radiation_levels_median_per_day = [{ malaga: [0.001,0.01,1,10,100], with: 'points' }, { granada: [1,10,100,100,1000] } ]
  grada = Grada.new(radiation_days, radiation_levels_median_per_day)
  ...
end
```

* Just show

```ruby
grada.display( title: 'Atomic Device X in 2 cities', x_label: 'Frequency', y_label: 'smSv/day_one' )
```

### In order to create a histogram for analyzing the distribution. 

```ruby
class AtomicDevice
  ...
  radiation_levels_day_one = [0.001,0.01,1,0.001,0.001, 0.01, 0.01, 1, 0.01, 1, 0.01, 0.001, 0.001, 0.001, 0.001]
  grada = Grada.new(radiation_levels_day_one)
  ...
end
```

* Just show

```ruby
grada.display( graph_type: :histogram, title: 'Atomic Device X', x_label: 'Frequency', y_label: 'smSv/day_one' )
```

* Save plot

```ruby
grada.save( filename: 'secret/radiation_levels/ffa/zonex/devicex/radiation_level_malaga.png' ,graph_type: :histogram, title: 'Atomic Device X', x_label: 'Frequency', y_label: 'smSv/day_one' )
```
### In order to create a heatmap for comparing and visualizing data.

```ruby
class AtomicDevice
  ...
  devices = { 0 => 'Device X', 1 => 'Device Y', 2 => 'Device Z' }
  radiation_difference_between_devices = [[0, 1000, 0.01],[1000, 0, 0.1],[0.01, 0.1, 0]]
  grada = Grada.new(radiation_difference_between_devices)
  ...
end
```

### It is important to specify the min and the max parameters, so you get a reasonable distribution of colors for the heatmap you want

* Just show

```ruby
grada.display( graph_type: :heatmap, title: 'Atomic Device Comparison', x_label: 'Difference', min: 0, max: 1)
```

* Save plot

```ruby
grada.save( filename: 'secret/radiation_levels/ffa/zonex/devicex/radiation_level_malaga.png' ,graph_type: :heatmap, title: 'Atomic Device Comparison', x_label: 'Difference', min: 0, max: 1)
```

