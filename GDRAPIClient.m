#import "GDRAPIClient.h"
#import "AFNetworkingHelper.h"

@implementation GDRAPIClient

+ (instancetype)shared {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(void)internalRequestWithDict:(NSDictionary*)dict isPostMethod:(BOOL)isPost path:(NSString*)strPath isJSONResponse:(BOOL)isJSON useToken:(BOOL)useToken isCache:(BOOL)iscache successBlock:(void(^)(NSURLSessionDataTask *task, id responseObject))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure{
    
    NSString* url = [[[gdrUtils sharedUtils] hostInfo] stringByAppendingString:strPath];

    [self log:url];
    
    if (iscache) {
        [[AFNetworkingHelper sharedClient] internalRequestWithDict:dict isPostMethod:isPost path:url isJSONResponse:isJSON useToken:useToken isCache:iscache successBlock:success failure:failure];
    } else {
        [[AFNetworkingHelper sharedClient] internalRequestWithDict:dict isPostMethod:isPost path:url isJSONResponse:isJSON useToken:useToken successBlock:success failure:failure];
    }
}
    
-(void) setToken: (NSString*) token {
    gdrUtils.sharedUtils.token = token;
}
-(NSURLSessionDataTask*)internalRequest:(NSDictionary*)dict method:(int)method path:(NSString*)strPath isJSONResponse:(BOOL)isJSON useToken:(BOOL)useToken isCache:(BOOL)iscache successBlock:(void(^)(NSURLSessionDataTask *task, id responseObject))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString* url = [[[gdrUtils sharedUtils] hostInfo] stringByAppendingString:strPath];
    
    [self log:url];
    
    return [[AFNetworkingHelper sharedClient] internalRequest:dict method:method path:url isJSONResponse:isJSON useToken:useToken isCache:iscache successBlock:success failure:failure];
}

-(void) log: (NSString*) url {
    if (self.isDebug){
        NSLog(@"API Client URL Requested: %@",url);
        NSLog(@"API Client Access Token: %@",gdrUtils.sharedUtils.token);
    }
}
@end
