//
//  VCWebServ.m
//  repeater
//
//  Created by admin on 2016. 9. 27..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "VCWebServ.h"
#import "KSPath.h"
#import "MyHTTPConnection.h"
#import "TblContFileHelper.h"
#import "SSZipArchive.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@interface VCWebServ ()

@end

static VCWebServ* instance = nil;

@implementation VCWebServ

+ (VCWebServ*)shared
{
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (instance == nil)
        instance = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)GetOurIpAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

- (void)startWebServ
{
    if ((self.httpServer != nil) && (self.httpServer.isRunning))
    {
        NSLog(@"이미 서버가 작동중임");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.prgUploading.progress = 0.0;
        self.lblStatus.text = @"Ready to upload";
    });
    
    // Configure our logging framework.
    // To keep things simple and fast, we're just going to log to the Xcode console.
    // [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Initalize our http server
    self.httpServer = [[HTTPServer alloc] init];
    
    // Tell the server to broadcast its presence via Bonjour.
    // This allows browsers such as Safari to automatically discover our service.
    [self.httpServer setType:@"_http._tcp."];
    
    // Normally there's no need to run our server on any specific port.
    // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
    // However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [self.httpServer setPort:80];
    
    // Serve files from the standard Sites folder
    //NSString *docRoot = [[[KSPath shared] bundlePath] stringByAppendingString:@"/index.html"];
    NSString *docRoot = [[[KSPath shared] documentPath] stringByAppendingString:@"/_web/"];
    if ([[KSPath shared] isExistPath:docRoot] == NO)
    {
        //NSLog(@"root dir not found:%@", docRoot);
        [[KSPath shared] createDirectory:docRoot];
        [[KSPath shared] copyFileFromBundle:@"index.html" toDocument:@"/_web/index.html"];
        [[KSPath shared] copyFileFromBundle:@"upload.html" toDocument:@"/_web/upload.html"];
        
        NSString* srcPath = [[[KSPath shared] bundlePath] stringByAppendingString:@"/webpage.zip"];
        if ([[KSPath shared] isExistPath:srcPath] == YES)
        {
            // 압축해제
            NSString* dstPath = [[[KSPath shared] documentPath] stringByAppendingString:@"/_web/"];
            [SSZipArchive unzipFileAtPath:srcPath toDestination:dstPath];
        }
    }
    
    [self.httpServer setDocumentRoot:docRoot];
    
    [self.httpServer setConnectionClass:[MyHTTPConnection class]];
    
    NSError *error = nil;
    if(![self.httpServer start:&error])
    {
        NSLog(@"Error starting HTTP Server: %@", error);
    }
    
    self.lblAddr.text = [NSString stringWithFormat:@"http://%@", [self GetOurIpAddress]];
}

- (void)stopWebServ
{
    if ((self.httpServer != nil) && (self.httpServer.isRunning))
    {
        [self.httpServer stop];
        self.httpServer = nil;
        //NSLog(@"웹서버 꺼짐");
    }
}

- (void)uploadingProcess:(NSString*)pFilename
                  totLen:(NSInteger)pTotLen
                  curLen:(NSInteger)pCurLen
{
    //NSLog(@"업로딩");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lblStatus.text = [NSString stringWithFormat:@"Uploading %@", pFilename];
    });
    
    if ((pTotLen == 0) || (pCurLen == 0))
        return;
    
    float percent = (float)pCurLen / (float)pTotLen;
    //NSLog(@"퍼센트:%.4f 현재길이:%li 전체길이:%li", percent, pCurLen, pTotLen);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.prgUploading.progress = percent;
    });
}

- (void)uploadingComplete:(NSString*)pFilename
                   totLen:(NSInteger)pTotLen
{
    //NSLog(@"완료");
    
    // 파일이동
    NSString* srcPath = [NSString stringWithFormat:@"%@/_web/upload/%@",
                        [[KSPath shared] documentPath], pFilename];
    
    NSString* dstPath = [NSString stringWithFormat:@"%@/%@",
                        [TblContFileHelper shared].needHelp.currDir, pFilename];
    
    // 이미 존재한다면 파일업로딩 완료시 2번 호출되면 리턴시킨다
    if ([[KSPath shared] isExistPath:dstPath] == YES)
        return;
    
    [[KSPath shared] moveFile:srcPath targetPath:dstPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.prgUploading.progress = 0.0;
        self.lblStatus.text = @"Ready to upload";
        
        [self.vcParent userUploadingComplete:dstPath];
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
