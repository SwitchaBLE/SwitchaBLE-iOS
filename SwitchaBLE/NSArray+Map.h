//
//  NSArray+NSArray_Blocks.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 11/14/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Map)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;

@end
