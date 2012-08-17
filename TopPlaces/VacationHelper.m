//
//  VacationHelper.m
//  TopPlaces
//
//  Created by timnit gebru on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationHelper.h"
@interface VacationHelper()

@end

static NSMutableDictionary *vacationToDocumentMapping;

@implementation VacationHelper


+(void)openVacation:(NSString *)vacationName usingBlock: (completion_block_t)completionBlock
{

    if (!vacationToDocumentMapping){
        vacationToDocumentMapping = [[NSMutableDictionary alloc]init ];
    }
    
    UIManagedDocument *doc = [vacationToDocumentMapping objectForKey:vacationName];
    //NSLog(@"%@, %@", __FUNCTION__, [vacationToDocumentMapping objectForKey:vacationName]);
    
    if(doc) {
           
         if (doc.documentState == UIDocumentStateClosed) {

             [doc openWithCompletionHandler:^(BOOL success) 
              { 
                  if (success) completionBlock (doc);
                  else NSLog(@"error opening existing db");
              }];

         } else if (doc.documentState == UIDocumentStateNormal) {
         // already open and ready to use
             completionBlock (doc);
             NSLog(@"opened existing db successfully");
         }
    }
    else {
        
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory 
                                                             inDomains:NSUserDomainMask] lastObject];
        
        NSString *anotherVacationName = @"My Vacation.db";
        url = [url URLByAppendingPathComponent: anotherVacationName];//vacationName];
        // url is now "<Documents Directory>/Default Photo Database"
        UIManagedDocument *database = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
        
        [vacationToDocumentMapping setObject:database forKey:vacationName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
            
            [database saveToURL:database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) 
             { 
                 if (success) {
                     completionBlock(database);
                 }else 
                     NSLog(@"%s, problem creating db", __FUNCTION__);}];
        }
        else {
            NSLog(@"DB exists on disk, no need to create");
            if (database.documentState == UIDocumentStateClosed) {
                
                [database openWithCompletionHandler:^(BOOL success) 
                 { 
                     if (success) completionBlock (database);
                     else NSLog(@"error opening existing db");
                 }];
                
            } else if (database.documentState == UIDocumentStateNormal) {
                // already open and ready to use
                NSLog(@"opened existing db successfully");
                completionBlock (database);
            }

        }
    }
    
}




@end
