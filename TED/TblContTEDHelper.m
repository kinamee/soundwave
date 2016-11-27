//
//  TblContVOAHelper.m
//  repeater
//
//  Created by admin on 2016. 2. 9..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblContTEDHelper.h"
#import "TFHpple.h"
#import "TblContTED.h"
#import "Config.h"
#import "KSPath.h"

static TblContTEDHelper* instance = nil;

@implementation TblContTEDHelper

+ (TblContTEDHelper*)shared
{
    if (instance == nil) {
        instance = [[TblContTEDHelper alloc] init];
    }
    return instance;
}

- (void)trimmed:(NSString**)pString
{
    *pString = [*pString stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)analizeHtml:(NSString*)pUrl
  handlerOnComplete:(void(^)(NSDictionary* pMovieInfo))phandlerOnComplete;
{
    NSURL *URL = [NSURL URLWithString:pUrl];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:URL
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error)
    {
        TFHpple* parser = [TFHpple hppleWithHTMLData:data];
        NSMutableString* xPath = [NSMutableString string];
        [xPath appendFormat:@"//div[@role[contains(.,'main')]]"];
        [xPath appendFormat:@"/div[@class[contains(.,'container')]]"];
        [xPath appendFormat:@"/div[@class[contains(.,'row')]]"];
        [xPath appendFormat:@"/div[@class='col']"];
        //NSLog(@"XPATH: %@", xPath);
        
        NSMutableDictionary* dictMovieInfo = [NSMutableDictionary dictionary];
        NSArray* arrNode = [parser searchWithXPathQuery:xPath];
        for (TFHppleElement *element in arrNode)
        {
            // 1. FIND LINK TO DETAIL PAGE
            NSString* xPathLinkToDetail = @"//a[@href[contains(.,'/talks/')]]";
            TFHppleElement* nodeOfLinkToDetail = [[element searchWithXPathQuery:xPathLinkToDetail] objectAtIndex:0];
            NSString* linkToDetail = [nodeOfLinkToDetail.attributes objectForKey:@"href"];
            NSString* duration = nodeOfLinkToDetail.content;
            [self trimmed:&duration];
            
            if ([linkToDetail hasPrefix:@"/talks"])
                linkToDetail = [NSString stringWithFormat:@"https://www.ted.com%@", linkToDetail];            
            //NSLog(@"디테일링크: %@", linkToDetail);
            
            // 2. FIND IMAGE SOURCE
            NSString* xPathImageSource = @"//img[@class[contains(.,'thumb')]]";
            TFHppleElement* nodeOfImage = [[element searchWithXPathQuery:xPathImageSource] objectAtIndex:0];
            NSString* imageSource = [nodeOfImage.attributes objectForKey:@"src"];
            // NSLog(@"이미지소스: %@", imageSource);
            
            // 3. FIND PUBLISHED DATE
            NSString* xPathPublished = @"//span[@class='meta__val']";
            TFHppleElement* nodeOfDate = [[element searchWithXPathQuery:xPathPublished] objectAtIndex:0];
            NSString* published = nodeOfDate.content;
            [self trimmed:&published];
            published = [NSString stringWithFormat:@"%@", published];
            // NSLog(@"업로드날짜: %@", published);
            
            // 4. FIND MOVIE TITLE
            NSString* xPathTitle = @"//h4[@class[contains(.,'h9')]]/a";
            TFHppleElement* nodeOfTitle = [[element searchWithXPathQuery:xPathTitle] objectAtIndex:0];
            NSString* movieTitle = nodeOfTitle.content;
            [self trimmed:&movieTitle];
            // NSLog(@"무비타이틀: %@", movieTitle);
            
            // CREATE MOVIE OBJECT
            MovieInfo* movie = [[MovieInfo alloc] init];
            movie.linkToDetailPage = linkToDetail;
            movie.linkToThumb = imageSource;
            movie.pubDateTime = published;
            movie.movieTitle = movieTitle;
            movie.durationTime = duration;
                 
            [dictMovieInfo setValue:movie forKey:@(dictMovieInfo.count).stringValue];
        }
        
        phandlerOnComplete(dictMovieInfo);
    }] resume];
}

/*---------------------------------------------
 GET RENEW NAME FROM PROMPT-ALERT-VIEW
 ----------------------------------------------*/
- (void)newNamePrompt:(NSString*)pDefaultName
                title:(NSString*)pTitle
              message:(NSString*)pMessage
    handlerOnComplete:(void(^)(NSString* pNewName))phandlerOnComplete;
{
    TblContTED* controller = self.needHelp;
    
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
    //TFHpple* parser = [TFHpple hppleWithHTMLData:pHtmlData];
    
    // 1. HTML 텍스트에서 http://download.ted.com/talks/GregoryHeyworth_2015X-480p-en.mp4" 형태를 찾아라
    NSString* html = [[NSString alloc] initWithData:pHtmlData encoding:NSUTF8StringEncoding];
    NSArray* arrHtml = [html componentsSeparatedByString:@"\n"];
    
    for (NSInteger i = 0; i < arrHtml.count; i++)
    {
        NSString* aLine = [arrHtml objectAtIndex:i];
        if ([aLine hasPrefix:@"<script>"])
            if ([aLine rangeOfString:@"http://download.ted.com/talks/"].location != NSNotFound)
            {
                NSUInteger idxBackFrom = [aLine rangeOfString:@"-en.mp4"].location;
                if (idxBackFrom != NSNotFound)
                {
                    for (NSUInteger j = idxBackFrom; j > (idxBackFrom - 100); j--)
                    {
                        NSRange range = NSMakeRange(j, 4);
                        if ([[aLine substringWithRange:range] isEqualToString:@"http"])
                        {
                            range = NSMakeRange(j, idxBackFrom - j + 7);
                            // NSLog(@"링크발견: %@", [aLine substringWithRange:range]);
                            return [aLine substringWithRange:range];
                        }
                    }
                }
            }
    }
    
    // 2. 자막없는 mp4 찾아라
    // "nativeDownloads":{"low":"http://download.ted.com/talks/MelatiWijsen_2015G-light.mp4
    for (NSInteger i = 0; i < arrHtml.count; i++)
    {
        NSString* aLine = [arrHtml objectAtIndex:i];
        if ([aLine hasPrefix:@"<script>"])
        {
            NSUInteger idxStartFrom = [aLine rangeOfString:@"nativeDownloads"].location;
            if (idxStartFrom != NSNotFound)
            {
                aLine = [aLine substringFromIndex:idxStartFrom];
                idxStartFrom = [aLine rangeOfString:@"http://download"].location;
                if (idxStartFrom != NSNotFound)
                {
                    aLine = [aLine substringFromIndex:idxStartFrom];
                    NSUInteger idxEnd = [aLine rangeOfString:@".mp4"].location;
                    if (idxStartFrom != NSNotFound)
                    {
                        aLine = [aLine substringToIndex:idxEnd + 4];
                        //NSLog(@"다운로드 링크:%@", aLine);
                        return aLine;
                    }
                }
            }
        }
    }
    
    //NSLog(@"TED 다운로드 링크 없음: 총라인수 %li: 총글자수: %li", arrHtml.count, html.length);
    return nil;
}

- (void)downloadLinkFromDetailPage:(NSString*)pDetailPage handlerOnComplete:(void(^)(NSString* pDownloadLink))phandlerOnComplete;
{
    
    if ([pDetailPage hasPrefix:@"/talks"])
        pDetailPage = [NSString stringWithFormat:@"https://www.ted.com%@", pDetailPage];
    
    NSURL *URL = [NSURL URLWithString:pDetailPage];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:URL
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error)
    {
        // 1. HTML 텍스트에서 "high":"http://download.ted.com/talks/GregoryHeyworth_2015X-480p-en.mp4" 형태를 찾아라
        NSString* html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray* arrHtml = [html componentsSeparatedByString:@"\r\n"];
        
        for (NSInteger i = 0; i < arrHtml.count; i++)
        {
            NSString* aLine = [arrHtml objectAtIndex:i];
            if ([aLine hasPrefix:@"<script>"])
                if ([aLine rangeOfString:@"http://download.ted.com/talks/"].location != NSNotFound)
                    if ([aLine rangeOfString:@"-en.mp4"].location != NSNotFound)
                    {
                        //NSLog(@"다운로드 링크 발견");
                    }
        }
        
        /*TFHpple* parser = [TFHpple hppleWithHTMLData:data];
        
        // 1. "*-en.mp4" 파일이 있는 경우 (view-source:https://www.ted.com/talks/gregory_heyworth_how_i_m_discovering_the_secrets_of_ancient_texts)
        // 2. 없는데 대신 스크립트 페이지가 있는 경우 (https://www.ted.com/talks/mike_velings_the_case_for_fish_farming)
        // 3. 파일도 없고 스크립트 페이지도 없는 경우
        
        NSMutableString* xPath = [NSMutableString string];
        [xPath appendFormat:@"//div[@class='talk-download__video']"];
        [xPath appendFormat:@"//a[@href[contains(.,'en.mp4')]]"];
        NSLog(@"XPATH: %@", xPath);
        
        NSArray* arrNode = [parser searchWithXPathQuery:xPath];
        //NSLog(@"다운로드 링크개수: %li", arrNode.count);
        TFHppleElement* node = [arrNode objectAtIndex:arrNode.count-1];
        phandlerOnComplete([node.attributes valueForKey:@"href"]);*/
    }] resume];
}

@end
