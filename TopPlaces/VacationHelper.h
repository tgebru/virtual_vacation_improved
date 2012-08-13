//
//  VacationHelper.h
//  TopPlaces
//
//  Created by timnit gebru on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completion_block_t)(UIManagedDocument *vacation);
@interface VacationHelper : NSObject

+(void)openVacation:(NSString *)vacationName
         usingBlock: (completion_block_t)completionBlock;

@end
