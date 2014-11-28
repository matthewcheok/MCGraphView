//
//  ViewController.m
//  MCGraphViewDemo
//
//  Created by Matthew Cheok on 28/11/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import "ViewController.h"
#import <MCGraphView.h>

@interface ViewController () <MCGraphViewDelegate>

@property (strong, nonatomic) IBOutlet MCGraphView *graphView;

@end

@implementation ViewController

- (IBAction)randomizeLines:(id)sender {
    NSInteger numberOfLines = arc4random() % 3 + 2;
    
    NSMutableArray *lines = [NSMutableArray array];
    for (int i=0; i<numberOfLines; i++) {
        NSMutableArray *line = [NSMutableArray array];
        CGFloat current = arc4random() % 100;
        for (int j=0; j<15; j++) {
            CGPoint point = CGPointMake(j, MAX(current, 0));
            [line addObject:[NSValue valueWithCGPoint:point]];
            
            current += (CGFloat)(arc4random() % 40) - 20;
        }
        [lines addObject:[line copy]];
    }
    
    self.graphView.lineData = [lines copy];
    [self.graphView reloadDataAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.graphView layoutIfNeeded];
    
    self.graphView.delegate = self;
    self.graphView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    self.graphView.startAtZeroVertical = YES;
    
    self.graphView.lineStyle = MCGraphViewLineStyleSmooth;
    self.graphView.pointStyle = MCGraphViewPointStyleSquare;
    self.graphView.pointRadius = 3;
    
    [self randomizeLines:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: MCGraphViewDelegate

- (MCGraphViewPointStyle)graphView:(MCGraphView *)graphView pointStyleForLineAtIndex:(NSInteger)index {
    return (MCGraphViewPointStyle) arc4random() % 3;
}

- (MCGraphViewLineStyle)graphView:(MCGraphView *)graphView lineStyleForLineAtIndex:(NSInteger)index {
    return (MCGraphViewLineStyle) arc4random() % 2;
}

- (NSString *)graphView:(MCGraphView *)graphView titleStringForXValue:(CGFloat)value {
    return [NSString stringWithFormat:@"%.0f", 2000 + value];
}

- (NSString *)graphView:(MCGraphView *)graphView titleStringForYValue:(CGFloat)value {
    return [NSString stringWithFormat:@"%.0f", value];
}

- (void)graphView:(MCGraphView *)graphView willDisplayShapeLayer:(CAShapeLayer *)layer forLineAtIndex:(NSInteger)index {
    if (arc4random() % 2 == 0) {
        layer.lineDashPattern = @[@10, @5];
    }
}

@end
