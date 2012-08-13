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
    
    if(doc) {
           
         if (doc.documentState == UIDocumentStateClosed) {

             [doc openWithCompletionHandler:^(BOOL success) 
              { if (success) completionBlock (doc);}];

         } else if (doc.documentState == UIDocumentStateNormal) {
         // already open and ready to use
             completionBlock (doc);
         }
    }
    else {
        
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory 
                                                             inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:vacationName];
        // url is now "<Documents Directory>/Default Photo Database"
        UIManagedDocument *database = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
        
        [vacationToDocumentMapping setObject:database forKey:vacationName];
        
    
        [database saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) 
         { if (success) completionBlock (database);}]; 

    }
       
}




@end
