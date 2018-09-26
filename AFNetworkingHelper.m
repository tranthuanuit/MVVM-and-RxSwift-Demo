
#import "AFNetworkingHelper.h"
#import "Reachability.h"

#define VERSION 8
@interface AFNetworkingHelper()
{
}
@end

@implementation AFNetworkingHelper

+ (AFNetworkingHelper *)sharedClient {
    static AFNetworkingHelper *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        //session config
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sharedClient = [[self alloc] initWithSessionConfiguration:sessionConfiguration];
    });
    _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
    _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
    //    [_sharedClient.operationQueue cancelAllOperations];
    return _sharedClient;
}


- (instancetype)initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    return self;
}




//login
-(void)refreshTokenWithToken:(NSString*) refreshToken witUserId: (NSString*) userId
                     success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                     failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure
{
    if (refreshToken == nil || userId == nil) {
//        NSLog(@"Unable to refersh token, params are invalid");
        return;
    }
    
    NSString* path = [QD831URLManager loginURLString];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    
    
    NSDictionary *params = @{@"grant_type":@"refresh_token",@"refresh_token": refreshToken,@"UserId":userId};
    
    
    //    NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithDictionary:params];
    //    [dict setObject:[[QD831Utils sharedUtils] userCountry] forKey:@"country"];
    
    //Call request
    [manager POST:path parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task,responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task,error);
        }
    }];
}

//login
-(void)refreshEfftiTokenWithToken:(NSString*) refreshToken withUserId: (NSNumber*) userId
                          success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                          failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure
{
    if (refreshToken == nil || userId == nil) {
        return;
    }
    
    NSString* path = [QD831URLManager getEfftiRefreshToken];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    
    
    NSDictionary *params = @{@"grant_type":@"refresh_token",@"refresh_token": refreshToken,@"UserId":userId};
    
    //Call request
    [manager POST:path parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        if (success) {
            success(task,responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task,error);
        }
    }];
}

/**
 *  Private - Request message for internalRequestWithDict:::::
 */
-(void)privateEfftiRequestMessageQD831:(NSDictionary*)dict isPostMethod:(BOOL)isPost path:(NSString*)strPath isJSONResponse:(BOOL)isJSON useToken:(BOOL)useToken successBlock:(void(^)(NSURLSessionDataTask *task, id responseObject))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure{
    //Request
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (useToken==YES) {
        
        [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[[QD831Utils sharedUtils] EfftiToken]] forHTTPHeaderField:@"Authorization"];
    }
    
    if (isJSON==YES) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    else
    {
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    if (isPost==YES) {
        [self POST:strPath parameters:dict progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if (success) {
                success(task,responseObject);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (failure) {
                failure(task,error);
                NSHTTPURLResponse* respone = (NSHTTPURLResponse*)task.response;
                if (respone.statusCode == 500) {
                    UIAlertController *noInterNetAlert = [UIAlertController alertControllerWithTitle:@"Globedr" message:NSLocalizedString(@"serverErrorCode500", nil) preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *settingAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                    }];
                    [noInterNetAlert addAction:settingAction];
                }
                
                if (respone.statusCode == 401){
                    NSLog(@"Token expired!!!!!!!");
                    NSLog(@"%@",[[QD831Utils sharedUtils]refreshTokenEffi]);
                    [self refreshEfftiTokenWithToken:[QD831Utils sharedUtils].refreshTokenEffi withUserId:[[QD831Utils sharedUtils] UserId] success:^(NSURLSessionDataTask *task, id responseObject) {
                        [[QD831Utils sharedUtils] setEfftiToken:responseObject[@"access_token"]];
                        [[QD831Utils sharedUtils] setRefreshTokenEffi:responseObject[@"refresh_token"]];

                        [self privateEfftiRequestMessageQD831:dict isPostMethod:isPost path:strPath isJSONResponse:isJSON useToken:useToken successBlock:success failure:failure];
                        
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                        NSLog(@"Cannot refresh token!!!!!!!");
                    }];
                }
            }
        }];
    }
    else
    {
        [self GET:strPath parameters:dict progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if (success) {
                success(task,responseObject);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (failure) {
                NSHTTPURLResponse* respone = (NSHTTPURLResponse*)task.response;
                if (respone.statusCode == 500) {
                    UIAlertController *noInterNetAlert = [UIAlertController alertControllerWithTitle:@"Globedr" message:NSLocalizedString(@"serverErrorCode500", nil) preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *settingAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [noInterNetAlert addAction:settingAction];
 
                }
                
                if (respone.statusCode == 401){
                    NSLog(@"Token expired!!!!!!!");
                    NSLog(@"%@",[[QD831Utils sharedUtils]refreshTokenEffi]);
                    [self refreshEfftiTokenWithToken:[QD831Utils sharedUtils].refreshTokenEffi withUserId:[[QD831Utils sharedUtils] UserId] success:^(NSURLSessionDataTask *task, id responseObject) {
                        [[QD831Utils sharedUtils] setEfftiToken:responseObject[@"access_token"]];
                        [[QD831Utils sharedUtils] setRefreshTokenEffi:responseObject[@"refresh_token"]];
                        [self privateEfftiRequestMessageQD831:dict isPostMethod:isPost path:strPath isJSONResponse:isJSON useToken:useToken successBlock:success failure:failure];
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                        NSLog(@"Cannot refresh token!!!!!!!");
//                        [QD831Utils logoutUser];
                    }];
                } else {
                    failure(task,error);
                }
                
            }
        }];
    }
}
-(void)privateRequestMessage:(NSDictionary*)dict isPostMethod:(BOOL)isPost path:(NSString*)strPath isJSONResponse:(BOOL)isJSON useToken:(BOOL)useToken successBlock:(void(^)(NSURLSessionDataTask *task, id responseObject))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure{
    //Request
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.requestSerializer setValue:[NSString stringWithFormat:@"%d",VERSION] forHTTPHeaderField:@"Version"];
    if (useToken==YES) {
        [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[[QD831Utils sharedUtils] token]] forHTTPHeaderField:@"Authorization"];
    }
    //    NSLog(@"%@",[[QD831Utils sharedUtils] token]);
    if (isJSON==YES) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    else
    {
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    if (isPost==YES) {
        
        [self POST:strPath parameters:dict progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if (success) {
                success(task,responseObject);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (failure) {
//                [[[QD831Utils sharedUtils] getAppDelegate] checkInternetConnection];
                
                NSHTTPURLResponse* respone = (NSHTTPURLResponse*)task.response;
                if (respone.statusCode == 500) {
                    UIAlertController *noInterNetAlert = [UIAlertController alertControllerWithTitle:@"Globedr" message:NSLocalizedString(@"serverErrorCode500", nil) preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *settingAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [noInterNetAlert addAction:settingAction];
                }
                
                if (respone.statusCode == 401){
//                    NSLog(@"Token expired!!!!!!!");
                    [self refreshEfftiTokenWithToken:[QD831Utils sharedUtils].refreshTokenEffi withUserId:[QD831Utils sharedUtils].UserId success:^(NSURLSessionDataTask *task, id responseObject) {
                        [[QD831Utils sharedUtils] setEfftiToken:responseObject[@"access_token"]];
                        [[QD831Utils sharedUtils] setRefreshTokenEffi:responseObject[@"refresh_token"]];
                                                [self privateEfftiRequestMessageQD831:dict isPostMethod:isPost path:strPath isJSONResponse:isJSON useToken:useToken successBlock:success failure:failure];
                        
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        //                        NSLog(@"Cannot refresh token!!!!!!!");
                    }];

                } else {
                    failure(task,error);
                }
            }
        }];
        
    }
    else
    {
        [self GET:strPath parameters:dict progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if (success) {
                success(task,responseObject);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {

        }];
    }
}
-(void)internalRequestWithDictQD831:(NSDictionary *)dict isPostMethod:(BOOL)isPost path:(NSString *)strPath isJSONResponse:(BOOL)isJSON useToken:(BOOL)useToken successBlock:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure{
    if ([strPath containsString:@"http"] == NO)
    {
//        NSLog(@"Host Info is not ready");
        return;
    }
    else
    {
        [self privateEfftiRequestMessageQD831:dict isPostMethod:isPost path:strPath isJSONResponse:isJSON useToken:useToken successBlock:success failure:failure];
    }
    
}

-(void)internalEfftiRequestWithDIct:(NSDictionary*)dict isPostMethod:(BOOL)isPost path:(NSString*)strPath isJSONResponse:(BOOL)isJSON useToken:(BOOL)useToken successBlock:(void(^)(NSURLSessionDataTask *task, id responseObject))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure{
    if ([strPath containsString:@"http"] == NO)
    {
        return;
    }
    if ([[QD831Utils sharedUtils] canReachInternet]==NO) {
        //CHECK AGAIN
        Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
        
        if ([reachability isReachable]) {

            [self privateRequestMessage:dict isPostMethod:isPost path:strPath isJSONResponse:isJSON useToken:useToken successBlock:success failure:failure];
        }
    }
    else
    {
        [self privateRequestMessage:dict isPostMethod:isPost path:strPath isJSONResponse:isJSON useToken:useToken successBlock:success failure:failure];
    }
}







@end
