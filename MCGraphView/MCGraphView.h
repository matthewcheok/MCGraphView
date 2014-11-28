//
//  MCGraphView.h
//  MCGraphView
//
//  Created by Matthew Cheok on 28/11/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MCGraphViewLineStyle) {
    MCGraphViewLineStyleDefault = 0,
    MCGraphViewLineStyleSmooth
};

typedef NS_ENUM(NSInteger, MCGraphViewPointStyle) {
    MCGraphViewPointStyleNone = 0,
    MCGraphViewPointStyleCircle,
    MCGraphViewPointStyleSquare
};

@class MCGraphView;
@protocol MCGraphViewDelegate <NSObject>

@optional
- (NSString *)graphView:(MCGraphView *)graphView titleStringForXValue:(CGFloat)value;
- (NSString *)graphView:(MCGraphView *)graphView titleStringForYValue:(CGFloat)value;

- (MCGraphViewLineStyle)graphView:(MCGraphView *)graphView lineStyleForLineAtIndex:(NSInteger)index;
- (MCGraphViewPointStyle)graphView:(MCGraphView *)graphView pointStyleForLineAtIndex:(NSInteger)index;

- (void)graphView:(MCGraphView *)graphView willDisplayShapeLayer:(CAShapeLayer *)layer forLineAtIndex:(NSInteger)index;
- (void)graphView:(MCGraphView *)graphView willDisplayLabel:(UILabel *)label forXValue:(CGFloat)value;
- (void)graphView:(MCGraphView *)graphView willDisplayLabel:(UILabel *)label forYValue:(CGFloat)value;

@end

@interface MCGraphView : UIView

@property (nonatomic, weak) IBOutlet id <MCGraphViewDelegate> delegate;

@property (nonatomic, strong) NSArray *lineData; // An array of arrays of NSValue (CGPoint)
@property (nonatomic, strong) NSArray *lineColors;

@property (nonatomic, assign) MCGraphViewLineStyle lineStyle;
@property (nonatomic, assign) MCGraphViewPointStyle pointStyle;
@property (nonatomic, assign) CGFloat pointRadius;

@property (nonatomic, assign) CGFloat axisSpacingVertical;
@property (nonatomic, assign) CGFloat axisSpacingHorizontal;
@property (nonatomic, assign) NSInteger maximumLabelsVertical;
@property (nonatomic, assign) NSInteger maximumLabelsHorizontal;

@property (nonatomic, assign) BOOL startAtZeroVertical;
@property (nonatomic, assign) BOOL startAtZeroHorizontal;
@property (nonatomic, assign) UIEdgeInsets contentInset;

- (void)reloadData;
- (void)reloadDataAnimated:(BOOL)animated;

@end
