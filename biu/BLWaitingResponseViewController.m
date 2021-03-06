//
//  BLWaitingResponseViewController.m
//  biu
//
//  Created by Tony Wu on 7/6/15.
//  Copyright (c) 2015 BiuLove. All rights reserved.
//

#import "BLWaitingResponseViewController.h"
#import "BLMessagesViewController.h"
#import "Masonry.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BLTableViewCellParams : NSObject

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) UIColor *color;

@end

@interface BLWaitingResponseViewController () <UITableViewDataSource, UITableViewDelegate, BLMessagesViewControllerDelegate, BLMatchNotificationDelegate> {
    int secondsLeft;
    int minutes;
    int seconds;
}

@property (strong, nonatomic) UIImageView *background;
@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *lbTimeCounter;
@property (strong, nonatomic) UIButton *btnClose;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) User *currentUser;
@property (assign, nonatomic) NSInteger coupleState;
@property (assign, nonatomic) NSInteger coupleResult;

@end

@implementation BLWaitingResponseViewController

static const NSInteger BL_AVATAR_WIDTH = 80.0f;

#pragma mark -
#pragma mark Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    secondsLeft = 2 * 60;
    
    [self.view addSubview:self.background];
    [self.view addSubview:self.avatarImageView];
    [self.view addSubview:self.lbTimeCounter];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.btnClose];
    
    // Layout subviews
    [self layoutSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [self fetchUserMatchedInfo];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(matchedUserAccepted) name:@"matched user accepted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(matchedUserRejected) name:@"matched user rejected" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BLAppDelegate *blAppDelegate = (BLAppDelegate *)[[UIApplication sharedApplication] delegate];
    blAppDelegate.notificationDelegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    BLAppDelegate *blAppDelegate = (BLAppDelegate *)[[UIApplication sharedApplication] delegate];
    blAppDelegate.notificationDelegate = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"matched user accepted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"matched user rejected" object:nil];
}

#pragma mark Layouts
- (void)layoutSubViews {
    [self.background mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.background.superview);
    }];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImageView.superview).with.offset([BLGenernalDefinition resolutionForDevices:100.0f]);
        make.centerX.equalTo(self.avatarImageView.superview.mas_centerX);
        make.width.height.equalTo([NSNumber numberWithInteger:[BLGenernalDefinition resolutionForDevices:BL_AVATAR_WIDTH]]);
    }];
    
    [self.lbTimeCounter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImageView.mas_bottom).with.offset([BLGenernalDefinition resolutionForDevices:30.0f]);
        make.centerX.equalTo(self.lbTimeCounter.superview.mas_centerX);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lbTimeCounter.mas_bottom).with.offset([BLGenernalDefinition resolutionForDevices:40.0f]);
        make.left.right.equalTo(self.tableView.superview);
        make.height.equalTo([NSNumber numberWithDouble:[BLGenernalDefinition resolutionForDevices:180.0f]]);
    }];
    
    [self.btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.btnClose.superview).with.offset([BLGenernalDefinition resolutionForDevices:-80.0f]);
        make.centerX.equalTo(self.btnClose.superview.mas_centerX);
        make.width.height.equalTo([NSNumber numberWithDouble:[BLGenernalDefinition resolutionForDevices:60.0f]]);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public methods
- (void)matchedUserRejected {
    [self.timer invalidate];
    BLTableViewCellParams *param = [BLTableViewCellParams new];
    param.text = NSLocalizedString(@"matched user rejected", nil);
    param.icon = [UIImage imageNamed:@"warning_icon.png"];
    param.color = [BLColorDefinition fontGreenColor];
    [self.dataSource insertObject:param atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)matchedUserAccepted {
    NSLog(@"Matched user accepted.");
    [self.timer invalidate];
    BLMessagesViewController *messageViewController = [[BLMessagesViewController alloc] init];
    messageViewController.delegate = self;
    messageViewController.sender = self.currentUser;
    messageViewController.receiver = self.matchedUser;
    [self.navigationController pushViewController:messageViewController animated:YES];
}

#pragma mark -
#pragma mark Actions
- (void)close:(id)sender {
    [self.timer invalidate];
    [[BLHTTPClient sharedBLHTTPClient] match:self.currentUser event:BLMatchEventReject distance:nil matchedUser:self.matchedUser success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Timer up, back to matching view");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Update match state failed, error: %@", error.localizedDescription);
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [av show];
    }];
    [self.navigationController popToRootViewControllerAnimated:YES];
}



#pragma mark Timer callback
- (void)updateCounter {
    if (secondsLeft >= 0) {
        secondsLeft--;
        minutes = secondsLeft / 60;
        seconds = secondsLeft % 60;
        self.lbTimeCounter.text = [NSString stringWithFormat:@"%02d : %02d", minutes, seconds];
    } else {
        [self.timer invalidate];
        [[BLHTTPClient sharedBLHTTPClient] match:self.currentUser event:BLMatchEventTimout distance:nil matchedUser:self.matchedUser success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"Timer up, back to matching view");
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Update match state failed, error: %@", error.localizedDescription);
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [av show];
        }];
    }
}

#pragma mark - Delegates
#pragma mark TableView data source and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"datasource count: %lu", (unsigned long)self.dataSource.count);
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    BLTableViewCellParams *params = [self.dataSource objectAtIndex:indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = params.icon;
    
    [cell addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = params.color;
    label.numberOfLines = 2;
    label.font = [BLFontDefinition lightFont:15.0f];
    label.text = params.text;
    label.adjustsFontSizeToFitWidth = YES;
    [cell addSubview:label];
    
    // Draw top border only on first cell
    if (indexPath.row == 0) {
        UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.5)];
        topLineView.backgroundColor = [BLColorDefinition menuFontColor];
        [cell.contentView addSubview:topLineView];
    }
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.bounds.size.height, self.view.bounds.size.width, 0.5)];
    bottomLineView.backgroundColor = [BLColorDefinition menuFontColor];
    [cell.contentView addSubview:bottomLineView];
    
    cell.backgroundColor = [UIColor clearColor];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.superview).with.offset([BLGenernalDefinition resolutionForDevices:15.0f]);
        make.left.equalTo(imageView.superview).with.offset([BLGenernalDefinition resolutionForDevices:20.0f]);
        make.width.height.equalTo([NSNumber numberWithDouble:[BLGenernalDefinition resolutionForDevices:50.0f]]);
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.superview).with.offset([BLGenernalDefinition resolutionForDevices:19.0f]);
        make.left.equalTo(imageView.mas_right).with.offset([BLGenernalDefinition resolutionForDevices:20.0f]);
        make.right.equalTo(label.superview).with.offset([BLGenernalDefinition resolutionForDevices:-20.0f]);
    }];
    
    return cell;
}

#pragma mark MessageView Delegate
- (void)didDismissBLMessagesViewController:(BLMessagesViewController *)vc {
    [self.delegate didCloseConversation];
//    [[BLHTTPClient sharedBLHTTPClient] match:self.currentUser event:BLMatchEventClose distance:nil matchedUser:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"Stop conversation user successed.");
//        [self.delegate didCloseConversation];
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"Stop conversation faield.");
//    }];
}

#pragma mark MatchNotification delegates
- (void)receiveAcceptedNotification:(User *)matchedUser {
    NSLog(@"Matched user accepted.");
    [self.timer invalidate];
    BLMessagesViewController *messageViewController = [[BLMessagesViewController alloc] init];
    messageViewController.delegate = self;
    messageViewController.sender = self.currentUser;
    messageViewController.receiver = self.matchedUser;
    [self.navigationController pushViewController:messageViewController animated:YES];
}

- (void)receiveRejectedNotification {
    [self.timer invalidate];
    BLTableViewCellParams *param = [BLTableViewCellParams new];
    param.text = NSLocalizedString(@"matched user rejected", nil);
    param.icon = [UIImage imageNamed:@"warning_icon.png"];
    param.color = [BLColorDefinition fontGreenColor];
    [self.dataSource insertObject:param atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.timer invalidate];
}

#pragma mark - Private methods
- (void)fetchUserMatchedInfo {
    [[BLHTTPClient sharedBLHTTPClient] getMatchInfo:self.currentUser success:^(NSURLSessionDataTask *task, id responseObject) {
        [self.currentUser updateState:[[[responseObject objectForKey:@"user"] objectForKey:@"state"] integerValue]];
        self.coupleState = [[responseObject objectForKey:@"state"] integerValue];
        self.coupleResult = [[responseObject objectForKey:@"result"] integerValue];
        self.matchedUser = [[User alloc] initWithDictionary:[responseObject objectForKey:@"matched_user"]];

        if ((self.matchedUser.avatar_url == nil) || ([self.matchedUser.avatar_large_url isKindOfClass:[NSNull class]])) {
            
            self.avatarImageView.image = [UIImage imageNamed:@"Launch.png"];
        } else {

        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.matchedUser.avatar_large_url]
                                placeholderImage:[UIImage imageNamed:@"avatar_upload_icon.png"]
                                         options:SDWebImageRefreshCached | SDWebImageHandleCookies];
        }
        [self reloadViewController];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Get match info failed, error: %@.", error.localizedDescription);
    }];
}

- (void)reloadViewController {
    switch (self.coupleState) {
        case BLCoupleStateStart:
        {
            if (self.matchedUser.state == BLMatchStateWaiting) {
                NSLog(@"Matched user accepted.");
                [self.timer invalidate];
                BLMessagesViewController *messageViewController = [[BLMessagesViewController alloc] init];
                messageViewController.delegate = self;
                messageViewController.sender = self.currentUser;
                messageViewController.receiver = self.matchedUser;
                [self.navigationController pushViewController:messageViewController animated:YES];
            }
            break;
        }
        case BLCoupleStateCommunication:
        {
            BLMessagesViewController *messageViewController = [[BLMessagesViewController alloc] init];
            messageViewController.delegate = self;
            messageViewController.sender = self.currentUser;
            messageViewController.receiver = self.matchedUser;
            [self.navigationController pushViewController:messageViewController animated:YES];
            break;
        }
        case BLCoupleStateFinish:
        {
            if (self.coupleResult == BLCoupleResultReject) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            } else if (self.coupleResult == BLCoupleResultBeenRejected) {
                [self.timer invalidate];
                BLTableViewCellParams *param = [BLTableViewCellParams new];
                param.text = NSLocalizedString(@"matched user rejected", nil);
                param.icon = [UIImage imageNamed:@"warning_icon.png"];
                param.color = [BLColorDefinition fontGreenColor];
                [self.dataSource insertObject:param atIndex:0];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark Getter
- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.layer.cornerRadius = [BLGenernalDefinition resolutionForDevices:BL_AVATAR_WIDTH] * 0.5f;
        _avatarImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        _avatarImageView.layer.borderWidth = 2.0f;
        _avatarImageView.clipsToBounds = YES;
        
    }
    return _avatarImageView;
}

- (UILabel *)lbTimeCounter {
    if (!_lbTimeCounter) {
        _lbTimeCounter = [[UILabel alloc] init];
        _lbTimeCounter.font = [BLFontDefinition lightFont:60.0f];
        _lbTimeCounter.textAlignment = NSTextAlignmentCenter;
        _lbTimeCounter.textColor = [UIColor whiteColor];
    }
    return _lbTimeCounter;
}



- (UIButton *)btnClose {
    if (!_btnClose) {
        _btnClose = [[UIButton alloc] init];
        [_btnClose setImage:[UIImage imageNamed:@"matched_close_icon.png"] forState:UIControlStateNormal];
        [_btnClose addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnClose;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = [BLGenernalDefinition resolutionForDevices:80.0f];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return _tableView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        BLTableViewCellParams *param = [BLTableViewCellParams new];
        param.text = NSLocalizedString(@"notified matched user", nil);
        param.color = [BLColorDefinition menuFontColor];
        param.icon = [UIImage imageNamed:@"info_icon.png"];
        [_dataSource addObject:param];
    }
    return _dataSource;
}

- (UIImageView *)background {
    if (!_background) {
        _background = [[UIImageView alloc] init];
        _background.image = [UIImage imageNamed:@"login_signup_background.png"];
    }
    return _background;
}

- (User *)currentUser {
    if (!_currentUser) {
        _currentUser = [[User alloc] initWithFromUserDefault];
    }
    return _currentUser;
}

@end

@implementation BLTableViewCellParams

@synthesize text, icon, color;

@end
