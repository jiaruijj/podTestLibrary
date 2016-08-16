//
//  NSBundle+MyLibrary.m
//  Pods
//
//  Created by JR on 16/8/16.
//
//

#import "NSBundle+MyLibrary.h"
#import "FNDebugManager.h"

@implementation NSBundle (MyLibrary)


+ (NSBundle *)myLibraryBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[FNDebugManager class]];
    return bundle;
}

@end
