//
//  MCGraphView.m
//  MCGraphView
//
//  Created by Matthew Cheok on 28/11/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import "MCGraphView.h"

static CGFloat kDefaultLabelWidth = 40.0;
static CGFloat kDefaultLabelHeight = 12.0;

static CGFloat kDefaultLineWidth = 3.0;
static CGFloat kDefaultMargin = 20.0;

static CGFloat kDefaultAnimationDuration = 0.3;
static CGFloat kDefaultAnimationInterval = 0.3;

@interface MCGraphView ()

@property (nonatomic, strong) NSArray *verticalAxisLabels;
@property (nonatomic, strong) NSArray *horizontalAxisLabels;
@property (nonatomic, strong) NSMutableArray *lineLayers;

@property (nonatomic, assign) CGRect graphRect;
@property (nonatomic, assign) BOOL reloading;

@property (nonatomic, assign) CGFloat minX;
@property (nonatomic, assign) CGFloat maxX;
@property (nonatomic, assign) CGFloat minY;
@property (nonatomic, assign) CGFloat maxY;

@end

@implementation MCGraphView

- (instancetype)init {
	self = [super init];
	if (self) {
		[self setup];
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self setup];
}

- (void)setup {
	self.lineColors = @[
	        [UIColor colorWithRed:0.0 green:0.7407 blue:0.6107 alpha:1.0],
	        [UIColor colorWithRed:0.1743 green:0.5907 blue:0.8691 alpha:1.0],
	        [UIColor colorWithRed:0.9155 green:0.2931 blue:0.2075 alpha:1.0],
	        [UIColor colorWithRed:0.9499 green:0.7742 blue:0.0 alpha:1.0]
	    ];
	self.lineLayers = [NSMutableArray array];

	self.pointStyle = MCGraphViewPointStyleCircle;
	self.pointRadius = 2;

	self.contentInset = UIEdgeInsetsMake(kDefaultMargin, kDefaultMargin, kDefaultMargin, kDefaultMargin);

	self.axisSpacingVertical = 1;
	self.axisSpacingHorizontal = 1;

	self.maximumLabelsVertical = 5;
	self.maximumLabelsHorizontal = 5;
}

- (void)setLineData:(NSArray *)lineData {
	_lineData = lineData;
}

- (void)setLineColors:(NSArray *)lineColors {
	NSAssert(lineColors.count > 0, @"Need a minimum of one line color");
	_lineColors = lineColors;
}

- (void)reloadData {
	[self reloadDataAnimated:NO];
}

- (void)reloadDataAnimated:(BOOL)animated {
	if (self.reloading) {
		return;
	}


	if (animated) {
        self.reloading = YES;
        
        if (self.lineLayers.count > 0) {
            NSTimeInterval duration = kDefaultAnimationDuration +  (self.lineLayers.count-1) * kDefaultAnimationInterval;
            [self _animateLinesToVisible:NO];
            
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                typeof(self) strongSelf = weakSelf;
                [strongSelf _populateDataAnimated];
            });
        }
        else {
            [self _populateDataAnimated];
        }
	}
	else {
		[self _populateData];
	}
}

// MARK: Private

- (CGPoint)_transformedPoint:(CGPoint)point {
	CGFloat x = (point.x - self.minX) / (self.maxX - self.minX);
	CGFloat y = (point.y - self.minY) / (self.maxY - self.minY);
	return CGPointMake(CGRectGetMinX(self.graphRect) + x * CGRectGetWidth(self.graphRect), CGRectGetMaxY(self.graphRect) - y * CGRectGetHeight(self.graphRect));
}

- (void)_populateData {
	[self _reset];

	if ([self.lineData count] == 0) {
		return;
	}

	[self _computeAxes];
	[self _placeVerticalAxisLabels];
	[self _placeHorizontalAxisLabels];

	for (int i = 0; i < self.lineData.count; i++) {
		[self _drawLineAtIndex:i];
		[self _plotLineAtIndex:i];
	}
}

- (void)_populateDataAnimated {
    [self _populateData];
    [self _animateLinesToVisible:YES];
    
    NSTimeInterval duration = kDefaultAnimationDuration +  (self.lineLayers.count-1) * kDefaultAnimationInterval;
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        typeof(self) strongSelf = weakSelf;
        strongSelf.reloading = NO;
    });
}

- (void)_reset {
	self.layer.sublayers = nil;
	[self.lineLayers removeAllObjects];

	for (UILabel *label in self.verticalAxisLabels) {
		[label removeFromSuperview];
	}

	for (UILabel *label in self.horizontalAxisLabels) {
		[label removeFromSuperview];
	}
}

- (void)_computeAxes {
	self.minX = self.startAtZeroHorizontal ? 0 : MAXFLOAT;
	self.minY = self.startAtZeroVertical ? 0 : MAXFLOAT;

	self.maxX = self.startAtZeroHorizontal ? 0 : -MAXFLOAT;
	self.maxY = self.startAtZeroVertical ? 0 : -MAXFLOAT;

	for (NSArray *line in self.lineData) {
		for (NSValue *value in line) {
			CGPoint point = [value CGPointValue];
			if (!self.startAtZeroHorizontal && point.x < self.minX) {
				self.minX = point.x;
			}

			if (point.x > self.maxX) {
				self.maxX = point.x;
			}

			if (!self.startAtZeroVertical && point.y < self.minY) {
				self.minY = point.y;
			}

			if (point.y > self.maxY) {
				self.maxY = point.y;
			}
		}
	}

	// set minimum region size
	if (fabsf(self.maxX - self.minX) < self.axisSpacingHorizontal) {
		self.minX -= self.axisSpacingHorizontal;
		self.maxX += self.axisSpacingHorizontal;
	}

	if (fabsf(self.maxY - self.minY) < self.axisSpacingVertical) {
		self.minY -= self.axisSpacingVertical;
		self.maxY += self.axisSpacingVertical;
	}
	else {
		// apply padding to vertical axis
		CGFloat difference = self.maxY - self.minY;
		CGFloat padding = difference * 0.2;
		self.minY -= padding / 2;
		self.maxY += padding / 2;
	}

	// compute drawing region
	CGRect rect = self.bounds;
	rect.origin.x += self.contentInset.left;
	rect.origin.y += self.contentInset.top;
	rect.size.width -= self.contentInset.left + self.contentInset.right;
	rect.size.height -= self.contentInset.top + self.contentInset.bottom;

	// make space for labels on vertical axis
	rect.origin.x += kDefaultLabelWidth + kDefaultMargin;
	rect.size.width -= kDefaultLabelWidth + kDefaultMargin;

	// make space for labels on horizontal axis
	rect.size.height -= kDefaultLabelHeight + kDefaultMargin;

	self.graphRect = rect;
}

- (void)_placeVerticalAxisLabels {
	for (UILabel *label in self.verticalAxisLabels) {
		[label removeFromSuperview];
	}
	self.verticalAxisLabels = nil;

	__weak typeof(self) weakSelf = self;

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	    typeof(self) strongSelf = weakSelf;
	    CGFloat jump = strongSelf.axisSpacingVertical;
	    while ((strongSelf.maxY - strongSelf.minY) / jump > strongSelf.maximumLabelsVertical) {
	        jump += strongSelf.axisSpacingVertical;
		}

	    dispatch_async(dispatch_get_main_queue(), ^{
	        typeof(self) strongSelf = weakSelf;
	        NSMutableArray *labels = [NSMutableArray array];

	        CGFloat value = 0;
	        if (!strongSelf.startAtZeroVertical) {
	            value = ceil(strongSelf.minY / strongSelf.axisSpacingVertical) * strongSelf.axisSpacingVertical;
			}

	        while (value <= strongSelf.maxY) {
	            UILabel *label = [strongSelf _label];
	            label.textAlignment = NSTextAlignmentRight;

	            NSString *title = nil;
	            if ([strongSelf.delegate respondsToSelector:@selector(graphView:titleStringForYValue:)]) {
	                title = [strongSelf.delegate graphView:strongSelf titleStringForYValue:value];
				}
	            else {
	                title = [NSString stringWithFormat:@"%.2f", value];
				}

	            label.text = title;

	            CGPoint center = [self _transformedPoint:CGPointMake(strongSelf.minX, value)];
	            center.x -= kDefaultLabelWidth / 2 + kDefaultMargin;
	            label.center = center;

	            if ([strongSelf.delegate respondsToSelector:@selector(graphView:willDisplayLabel:forYValue:)]) {
	                [strongSelf.delegate graphView:self willDisplayLabel:label forYValue:value];
				}
	            [strongSelf addSubview:label];

	            [labels addObject:label];
	            value += jump;
			}

	        strongSelf.verticalAxisLabels = [labels copy];
		});
	});
}

- (void)_placeHorizontalAxisLabels {
	for (UILabel *label in self.horizontalAxisLabels) {
		[label removeFromSuperview];
	}
	self.horizontalAxisLabels = nil;

	__weak typeof(self) weakSelf = self;

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	    typeof(self) strongSelf = weakSelf;
	    CGFloat jump = strongSelf.axisSpacingHorizontal;
	    while ((strongSelf.maxX - strongSelf.minX) / jump > strongSelf.maximumLabelsHorizontal) {
	        jump += strongSelf.axisSpacingHorizontal;
		}

	    dispatch_async(dispatch_get_main_queue(), ^{
	        typeof(self) strongSelf = weakSelf;
	        NSMutableArray *labels = [NSMutableArray array];

	        CGFloat value = 0;
	        if (!strongSelf.startAtZeroHorizontal) {
	            value = ceil(strongSelf.minX / strongSelf.axisSpacingHorizontal) * strongSelf.axisSpacingHorizontal;
			}

	        while (value <= strongSelf.maxX) {
	            UILabel *label = [strongSelf _label];
	            label.numberOfLines = 0;

	            NSString *title = nil;
	            if ([strongSelf.delegate respondsToSelector:@selector(graphView:titleStringForXValue:)]) {
	                title = [strongSelf.delegate graphView:self titleStringForXValue:value];
				}
	            else {
	                title = [NSString stringWithFormat:@"%.2f", value];
				}

	            label.text = title;

	            CGPoint center = [self _transformedPoint:CGPointMake(value, self.minY)];
	            center.y += kDefaultLabelHeight / 2 + kDefaultMargin;

	            [label sizeToFit];
	            label.center = center;

	            if ([strongSelf.delegate respondsToSelector:@selector(graphView:willDisplayLabel:forXValue:)]) {
	                [strongSelf.delegate graphView:self willDisplayLabel:label forXValue:value];
				}
	            [strongSelf addSubview:label];

	            [labels addObject:label];
	            value += jump;
			}

	        strongSelf.horizontalAxisLabels = [labels copy];
		});
	});
}

- (void)_animateLinesToVisible:(BOOL)visible {
    for (int i = 0; i < self.lineLayers.count; i++) {
        CAShapeLayer *layer = self.lineLayers[i];
        CABasicAnimation *animation = nil;
        
        if (visible) {
            animation = [self _animationWithKeyPath:@"strokeEnd"];
        }
        else {
            animation = [self _animationWithKeyPath:@"strokeStart"];
        }
        
        animation.duration += kDefaultAnimationInterval * i;
        [layer addAnimation:animation forKey:@"strokeAnimation"];
    }
}

- (void)_plotLineAtIndex:(NSInteger)index {
	MCGraphViewPointStyle style = self.pointStyle;
	if ([self.delegate respondsToSelector:@selector(graphView:pointStyleForLineAtIndex:)]) {
		style = [self.delegate graphView:self pointStyleForLineAtIndex:index];
	}

	if (style == MCGraphViewPointStyleNone) {
		return;
	}

	NSArray *points = self.lineData[index];

	for (int i = 0; i < [points count]; i++) {
		UIBezierPath *path = nil;
		CAShapeLayer *layer = [self _strokeLayer];

		UIColor *color = self.lineColors[index % self.lineColors.count];
		layer.strokeColor = [color CGColor];
		layer.fillColor = [color CGColor];
		[self.layer addSublayer:layer];

		CGPoint p1 = [self _transformedPoint:[points[i] CGPointValue]];

		if (style == MCGraphViewPointStyleCircle) {
			path = [UIBezierPath bezierPathWithArcCenter:p1 radius:self.pointRadius startAngle:0 endAngle:2 * M_PI clockwise:YES];
		}
		else if (style == MCGraphViewPointStyleSquare) {
			path = [UIBezierPath bezierPathWithRect:CGRectMake(p1.x - self.pointRadius, p1.y - self.pointRadius, self.pointRadius * 2, self.pointRadius * 2)];
		}
		layer.path = path.CGPath;
	}
}

- (void)_drawLineAtIndex:(NSInteger)index {
	// http://stackoverflow.com/questions/19599266/invalid-context-0x0-under-ios-7-0-and-system-degradation
	UIGraphicsBeginImageContext(self.frame.size);

	UIBezierPath *path = [self _bezierPath];
	CAShapeLayer *layer = [self _strokeLayer];

	if ([self.delegate respondsToSelector:@selector(graphView:willDisplayShapeLayer:forLineAtIndex:)]) {
		[self.delegate graphView:self willDisplayShapeLayer:layer forLineAtIndex:index];
	}

	UIColor *color = self.lineColors[index % self.lineColors.count];
	layer.strokeColor = [color CGColor];
	[self.layer addSublayer:layer];

	MCGraphViewLineStyle lineStyle = self.lineStyle;
	if ([self.delegate respondsToSelector:@selector(graphView:lineStyleForLineAtIndex:)]) {
		lineStyle = [self.delegate graphView:self lineStyleForLineAtIndex:index];
	}

	NSArray *points = self.lineData[index];

	for (int i = 0; i < [points count] - 1; i++) {
		CGPoint p1 = [self _transformedPoint:[points[i] CGPointValue]];
		CGPoint p2 = [self _transformedPoint:[points[i + 1] CGPointValue]];

		[path moveToPoint:p1];

		if (lineStyle == MCGraphViewLineStyleSmooth) {
			CGFloat tensionBezier1 = 0.3;
			CGFloat tensionBezier2 = 0.3;
			CGPoint p0 = p1;
			CGPoint p3 = p2;

			if (i > 0) { // Exception for first line because there is no previous point
				p0 = [self _transformedPoint:[points[i - 1] CGPointValue]];
			}
			else {
				tensionBezier1 = 0;
			}

			if (i < [points count] - 2) { // Exception for last line because there is no next point
				p3 = [self _transformedPoint:[points[i + 2] CGPointValue]];
			}
			else {
				tensionBezier2 = 0;
			}

			// First control point
			CGPoint CP1 = CGPointMake(p1.x + (p2.x - p1.x) / 3,
			                          p1.y - (p1.y - p2.y) / 3 - (p0.y - p1.y) * tensionBezier1);

			// Second control point
			CGPoint CP2 = CGPointMake(p1.x + 2 * (p2.x - p1.x) / 3,
			                          (p1.y - 2 * (p1.y - p2.y) / 3) + (p2.y - p3.y) * tensionBezier2);



			[path addCurveToPoint:p2 controlPoint1:CP1 controlPoint2:CP2];
		}
		else {
			[path addLineToPoint:p2];
		}
	}

	layer.path = path.CGPath;
	[self.lineLayers addObject:layer];

	UIGraphicsEndImageContext();
}

- (UILabel *)_label {
	CGRect frame = CGRectMake(0, 0, kDefaultLabelWidth, kDefaultLabelHeight);
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.font = [UIFont boldSystemFontOfSize:12];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [UIColor lightGrayColor];
	return label;
}

- (UIBezierPath *)_bezierPath {
	UIBezierPath *path = [UIBezierPath bezierPath];
	path.lineCapStyle = kCGLineCapRound;
	path.lineJoinStyle = kCGLineJoinRound;
	path.lineWidth = kDefaultLineWidth;
	return path;
}

- (CAShapeLayer *)_strokeLayer {
	CAShapeLayer *layer = [CAShapeLayer layer];
	layer.fillColor = [[UIColor blackColor] CGColor];
	layer.lineCap = kCALineCapRound;
	layer.lineJoin  = kCALineJoinRound;
	layer.lineWidth = kDefaultLineWidth;
	layer.fillColor = [[UIColor clearColor] CGColor];
	layer.strokeColor = [[UIColor redColor] CGColor];
	layer.strokeEnd = 1;
	return layer;
}

- (CABasicAnimation *)_animationWithKeyPath:(NSString *)keyPath {
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	animation.duration = kDefaultAnimationDuration;
	animation.fromValue = @(0);
	animation.toValue = @(1);
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
	return animation;
}

@end
