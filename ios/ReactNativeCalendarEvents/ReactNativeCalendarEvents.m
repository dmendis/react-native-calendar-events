//
//  ReactNativeCalendarEvents.m
//  ReactNativeCalendarEvents
//
//  Created by Dineth Mendis on 16/05/2016.
//  Copyright © 2016 M2D2 Pty Ltd. All rights reserved.
//

#import "ReactNativeCalendarEvents.h"
#import <EventKit/EventKit.h>

@implementation ReactNativeCalendarEvents

RCT_EXPORT_MODULE();


#pragma mark - Init & Permissions

+ (id)eventsStore {
    static EKEventStore *eventsStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        eventsStore = [EKEventStore new];
    });
    return eventsStore;
}

RCT_EXPORT_METHOD(initEventsDatabase) {
    [ReactNativeCalendarEvents eventsStore];
    NSLog(@"ReactNativeCalendarEvents: Events database initialized.");
}

RCT_EXPORT_METHOD(requestAccess:(RCTResponseSenderBlock)callback) {
    [[ReactNativeCalendarEvents eventsStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        NSLog(@"ReactNativeCalendarEvents: Permissions status: %@", granted ? @"Granted" : @"Denied");
        NSArray *callbackValues;
        if (granted && !error) {
            callbackValues = @[[NSNull null], [NSNumber numberWithBool:granted]];
        } else {
            callbackValues = @[error, [NSNumber numberWithBool:granted]];
        }
        callback(callbackValues);
    }];
}

#pragma mark - Get Events

RCT_REMAP_METHOD(getEvents,
                 month:(NSInteger)month
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    // Get the appropriate calendar
    EKEventStore *store = [ReactNativeCalendarEvents eventsStore];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create the start date components
    NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
    oneDayAgoComponents.day = -1;
    NSDate *oneDayAgo = [calendar dateByAddingComponents:oneDayAgoComponents
                                                  toDate:[NSDate date]
                                                 options:0];
    
    // Create the end date components
    NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
    oneYearFromNowComponents.year = 1;
    NSDate *oneYearFromNow = [calendar dateByAddingComponents:oneYearFromNowComponents
                                                       toDate:[NSDate date]
                                                      options:0];
    
    // Create the predicate from the event store's instance method
    NSPredicate *predicate = [store predicateForEventsWithStartDate:oneDayAgo
                                                            endDate:oneYearFromNow
                                                          calendars:nil];
    
    // Fetch all events that match the predicate
    NSArray *events = [store eventsMatchingPredicate:predicate];
    
    NSMutableArray *convertedEvents = [NSMutableArray arrayWithCapacity:events.count];
    for (EKEvent *event in events) {
        [convertedEvents addObject:@{
             @"title": event.title,
             @"startDate": [NSNumber numberWithDouble:[event.startDate timeIntervalSince1970]],
             @"endDate": [NSNumber numberWithDouble:[event.endDate timeIntervalSince1970]]
         }];
    }
    
    resolve(convertedEvents);
}

@end
