#import <Foundation/Foundation.h>

@interface GDRAPIClient : NSObject

@property (nonatomic,strong) NSString* rootAPIUrl;
@property (nonatomic,assign) BOOL isDebug;


+ (instancetype)shared;

-(void)internalRequestWithDict:(NSDictionary*)dict isPostMethod:(BOOL)isPost path:(NSString*)strPath isJSONResponse:(BOOL)isJSON useToken:(BOOL)useToken isCache:(BOOL)iscache successBlock:(void(^)(NSURLSessionDataTask *task, id responseObject))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;
-(void) setToken: (NSString*) token;
-(NSURLSessionDataTask*)internalRequest:(NSDictionary*)dict method:(int)method path:(NSString*)strPath isJSONResponse:(BOOL)isJSON useToken:(BOOL)useToken isCache:(BOOL)iscache successBlock:(void(^)(NSURLSessionDataTask *task, id responseObject))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
