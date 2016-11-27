//
//  TblContVOAHelper.m
//  repeater
//
//  Created by admin on 2016. 2. 9..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblContVOAHelper.h"
#import "TFHpple.h"
#import "TblContVOA.h"
#import "Config.h"
#import "KSPath.h"

static TblContVOAHelper* instance = nil;

@implementation TblContVOAHelper

+ (TblContVOAHelper*)shared
{
    if (instance == nil) {
        instance = [[TblContVOAHelper alloc] init];
    }
    return instance;
}

- (void)analizeHtml:(NSString*)pURL
  handlerOnComplete:(void(^)(NSDictionary* pMovieInfo))phandlerOnComplete
{
    
    NSURL *URL = [NSURL URLWithString:pURL];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:URL
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error)
    {
        NSDictionary* dictMovieInfo = [self movieInfoFromHTML:data];
        phandlerOnComplete(dictMovieInfo);
    }] resume];
}

- (NSDictionary*)movieInfoFromHTML:(NSData*)pHtml
{
    TFHpple* parser = [TFHpple hppleWithHTMLData:pHtml];
    NSMutableString* xPath = [NSMutableString string];
    [xPath appendFormat:@"//ul[@id[contains(.,'articleItems')]]"];
    [xPath appendFormat:@"/li[@class[contains(.,'col-xs')]]"];
    
    NSMutableDictionary* dictMovieInfo = [NSMutableDictionary dictionary];
    NSArray* arrNode = [parser searchWithXPathQuery:xPath];
    
    for (NSInteger i = 0; i < arrNode.count; i++)
    {
        TFHppleElement* element = [arrNode objectAtIndex:i];
        // 1. FIND LINK TO DETAIL PAGE
        //NSString* xPathLinkToDetail = @"//a[@class[contains(.,'img-wrapper')]]";
        NSString* xPathLinkToDetail = @"//a";
        //<a href="/a/review-lesson-20-24/3450511.html"
        TFHppleElement* nodeOfLinkToDetail = [[element searchWithXPathQuery:xPathLinkToDetail] objectAtIndex:0];
        NSString* linkToDetail = [nodeOfLinkToDetail.attributes objectForKey:@"href"];
        if ([linkToDetail hasPrefix:@"/a/"])
            linkToDetail = [NSString stringWithFormat:@"http://learningenglish.voanews.com%@", linkToDetail];
        //NSLog(@"디테일링크: %@", linkToDetail);
        
        // 3. FIND PUBLISHED DATE
        NSString* xPathPublished = @"//span[@class[contains(.,'date')]]";
        TFHppleElement* nodeOfDate = [[element searchWithXPathQuery:xPathPublished] objectAtIndex:0];
        NSString* published = nodeOfDate.content;
        //NSLog(@"업로드날짜: %@", published);
        
        // 4. FIND MOVIE TITLE
        NSString* xPathTitle = @"//span[@class[contains(.,'title')]]";
        TFHppleElement* nodeOfTitle = [[element searchWithXPathQuery:xPathTitle] objectAtIndex:0];
        NSString* movieTitle = nodeOfTitle.content;
        //NSLog(@"무비타이틀: %@", movieTitle);
        
        // 2. FIND IMAGE SOURCE
        NSString* xPathImageSource = @"//img";
        TFHppleElement* nodeOfImage = [[element searchWithXPathQuery:xPathImageSource] objectAtIndex:0];
        NSString* imageSource = [nodeOfImage.attributes objectForKey:@"src"];
        imageSource = [imageSource stringByReplacingOccurrencesOfString:@"w66" withString:@"w300"];
        //NSLog(@"이미지소스: %@", imageSource);
        
        // CREATE MOVIE OBJECT
        MovieInfo* movie = [[MovieInfo alloc] init];
        movie.linkToDetailPage = linkToDetail;
        movie.linkToThumb = imageSource;
        movie.pubDateTime = published;
        movie.movieTitle = movieTitle;
        movie.imgShot = nil;
        movie.htmlOfDetailPage = nil;
        
        [dictMovieInfo setValue:movie forKey:@(dictMovieInfo.count).stringValue];
    }
    return dictMovieInfo;
}

/*---------------------------------------------
 GET RENEW NAME FROM PROMPT-ALERT-VIEW
 ----------------------------------------------*/
- (void)newNamePrompt:(NSString*)pDefaultName
                title:(NSString*)pTitle
              message:(NSString*)pMessage
    handlerOnComplete:(void(^)(NSString* pNewName))phandlerOnComplete;
{
    TblContVOA* controller = self.needHelp;
    
    Config* trans = [Config shared];
    NSString* ttlForRename = [trans trans:pTitle];
    NSString* msgForRename = [trans trans:pMessage];
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:ttlForRename
                                message:msgForRename
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok =
    [UIAlertAction actionWithTitle:[trans trans:@"확인"]
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction * action)
     {
         UITextField *txtReName = alert.textFields.firstObject;
         dispatch_async(dispatch_get_main_queue(), ^{
             phandlerOnComplete(txtReName.text);
         });
     }];
    
    UIAlertAction* cc =
    [UIAlertAction actionWithTitle:[trans trans:@"취소"]
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {}];
    
    [alert addAction:cc];
    [alert addAction:ok];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // UIText 가운데정렬하고 블락잡아주자(블락잡기 실패)
        textField.textAlignment = NSTextAlignmentCenter;
        textField.text = pDefaultName;
        
    }];
    [alert.view setNeedsDisplay];
    [controller presentViewController:alert animated:YES completion:nil];
}

/*----------------------------------------
 FIND A LINK TO DOWNLOAD WITH HTML-SOURCE
 -----------------------------------------*/
- (NSString*)findLinkToDownload:(NSData*)pHtmlData
{
    TFHpple* parser = [TFHpple hppleWithHTMLData:pHtmlData];
    
    NSMutableString* xPath = [NSMutableString string];
    [xPath appendFormat:@"//audio[@data-type[contains(.,'audio/mp3')]]"];
    NSArray* arrNode = [parser searchWithXPathQuery:xPath];
    if (arrNode.count > 0)
    {
        TFHppleElement* node = [arrNode objectAtIndex:0];
        return [node.attributes valueForKey:@"src"];
    }
    
    return @"UNAVAILABLE";
}

/*------------------------------------
 RETRIEVE AND ANALYZE DURATION
 -------------------------------------*/
- (void)analizeHtmlForDuration:(NSString*)pURL
  handlerOnComplete:(void(^)(NSString* pDuration))phandlerOnComplete
{
    
    NSURL *URL = [NSURL URLWithString:pURL];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:URL
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error)
      {
          NSString* duration = [self findDuration:data];
          phandlerOnComplete(duration);
      }] resume];
}

/*--------------
 FIND DURATION
 ---------------*/
- (NSString*)findDuration:(NSData*)pHtmlData
{
    TFHpple* parser = [TFHpple hppleWithHTMLData:pHtmlData];
    
    NSMutableString* xPath = [NSMutableString string];
    [xPath appendFormat:@"//div[@class[contains(.,'embedded-audio')]]"];
    
    NSArray* arrNode = [parser searchWithXPathQuery:xPath];
    if (arrNode.count == 0)
        return @"UNAVAILABLE";
    
    TFHppleElement* node = [arrNode objectAtIndex:0];
    TFHppleElement* nodeDura = [[node searchWithXPathQuery:
                                 @"//span[@class[contains(.,'duration')]]"] objectAtIndex:0];
    //NSLog(@"듀레:%@", nodeDura.content);
    NSString* duration = [NSString stringWithFormat:@"%@",nodeDura.content];
    duration = [duration stringByReplacingOccurrencesOfString:@"(" withString:@""];
    duration = [duration stringByReplacingOccurrencesOfString:@")" withString:@""];
    return duration;
}

/*-----------
 FIND SCRIPT
 ------------*/
- (NSString*)findScript:(NSData*)pHtmlData
{
    TFHpple* parser = [TFHpple hppleWithHTMLData:pHtmlData];
    
    NSMutableString* xPath = [NSMutableString string];
    [xPath appendFormat:@"//body"];
    
    NSArray* arrNode = [parser searchWithXPathQuery:xPath];
    if (arrNode.count == 0)
        return nil;
    
    xPath = [NSMutableString stringWithFormat:@"//div[@class[contains(.,'wysiwyg')]]"];
    TFHppleElement* node = [arrNode objectAtIndex:0];
    arrNode = [node searchWithXPathQuery:xPath];
    if (arrNode.count ==0)
        return nil;
    
    xPath = [NSMutableString stringWithFormat:@"//p"];
    node = [arrNode objectAtIndex:0];
    arrNode = [node searchWithXPathQuery:xPath];
    if (arrNode.count ==0)
        return nil;
    
    NSMutableString* content = [NSMutableString string];
    for (NSInteger i = 0; i < arrNode.count; i++) {
        node = [arrNode objectAtIndex:i];
        
        NSString *trimed = [node.content stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([trimed hasPrefix:@"_____"])
            break;
        
        if ([trimed hasSuffix:@"I'm "])
            break;
        
        if ([trimed isEqualToString:@""] == NO)
            [content appendFormat:@"%@\n\n", node.content];
        //NSLog(@"%@", content);
        //content = [content stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
        //content = [content stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    }
    
    return content;
}

@end
