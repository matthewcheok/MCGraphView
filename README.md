MCGraphView ![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)
========================

[![Badge w/ Version](https://cocoapod-badges.herokuapp.com/v/MCGraphView/badge.png)](https://github.com/matthewcheok/MCGraphView)
[![Badge w/ Platform](https://cocoapod-badges.herokuapp.com/p/MCGraphView/badge.svg)](https://github.com/matthewcheok/MCGraphView)

A light-weight solution for displaying graphs.

##Screenshot
![Screenshot](https://raw.github.com/matthewcheok/MCGraphView/master/MCGraphViewDemo.gif "Example of MCGraphView")

## Installation

Add the following to your [CocoaPods](http://cocoapods.org/) Podfile

    pod 'MCGraphView', '~> 0.1'

or clone as a git submodule,

or just copy files in the ```MCGraphView``` folder into your project.

## Using MCGraphView

Add the `MCGraphView` class either programmatically or assign the custom class via storyboard. Then set the `lineData` property:

```
self.graphView.lineData = @[
  @[
    [NSValue valueWithCGPoint:CGPointMake(1, 20)],
    [NSValue valueWithCGPoint:CGPointMake(2, 40)],
    [NSValue valueWithCGPoint:CGPointMake(3, 20)],
    [NSValue valueWithCGPoint:CGPointMake(4, 60)],
    [NSValue valueWithCGPoint:CGPointMake(5, 40)],
    [NSValue valueWithCGPoint:CGPointMake(6, 140)],
    [NSValue valueWithCGPoint:CGPointMake(7, 80)],
  ],
  @[
    [NSValue valueWithCGPoint:CGPointMake(1, 40)],
    [NSValue valueWithCGPoint:CGPointMake(2, 20)],
    [NSValue valueWithCGPoint:CGPointMake(3, 60)],
    [NSValue valueWithCGPoint:CGPointMake(4, 100)],
    [NSValue valueWithCGPoint:CGPointMake(5, 60)],
    [NSValue valueWithCGPoint:CGPointMake(6, 20)],
    [NSValue valueWithCGPoint:CGPointMake(7, 60)],
  ]
];
```

The view automatically determines the ideal region to display based on the maximum and minimum values of your points.

More configuration options are available via the delegate protocol `MCGraphViewDelegate`. See the demo project for details.

## License

MCGraphView is under the MIT license.
