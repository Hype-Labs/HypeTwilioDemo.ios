//
// MIT License
//
// Copyright (C) 2015 Twilio Inc.
// Copyright (C) 2018 HypeLabs Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "ViewController.h"
#import <TwilioChatClient/TwilioChatClient.h>
#import "HYPBridgeController.h"

#pragma mark - Interface
@interface ViewController () <UITableViewDelegate, UITableViewDataSource, TwilioChatClientDelegate, UITextFieldDelegate, HYPBridgeControllerDelegate>

#pragma mark - IP Messaging Members
@property (strong, nonatomic) NSMutableOrderedSet *messages;
//@property (strong, nonatomic) TCHChannel *channel;
@property (strong, nonatomic) TwilioChatClient *client;
@property (strong, nonatomic) NSString *identity;
@property (strong, nonatomic) HYPTwilioChannel *channel;
@property (nonatomic, assign) BOOL netAccess;

#pragma mark - UI Elements
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (atomic, readonly) HYPBridgeController * bridgeController;

@end

#pragma mark - Implementation

@implementation ViewController
@synthesize bridgeController = _bridgeController;

- (HYPBridgeController *)hypBridgeController
{
    
    @synchronized(self) {
        
        if (_bridgeController == nil) {
            _bridgeController = [[HYPBridgeController alloc] init];
            _bridgeController.delegate = self;
            
        }
        return _bridgeController;
    }
}
#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) != nil) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) != nil) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    self.messages = [[NSMutableOrderedSet alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up tableview
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 66.0;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    // text field
    self.textField.delegate = self;
    
    // Dodge Keyboard when text field is selected
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    [self requestOwnTwilioClient];
    [self requestHypeToStart];
    
}

- (void)requestHypeToStart
{
    // Initialize Hype Framework
    [self.hypBridgeController requestHypeToStart];
    
}

- (void)requestOwnTwilioClient
{
    // Initialize Chat Client
    [self.hypBridgeController generateTwilioClient];
    
}

#pragma mark - UI Helpers
- (void)scrollToBottomMessage {
    if (self.messages.count == 0) {
        return;
    }
    
    int row = (int) [self.tableView numberOfRowsInSection:0] - 1;
    NSIndexPath *bottomMessageIndex = [NSIndexPath indexPathForRow:row
                                                         inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:bottomMessageIndex
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:NO];
}

- (void)addMessages:(NSMutableDictionary *)message {
    
    [self.messages addObjectsFromArray:@[message]];
    [self sortMessages];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if (self.messages.count > 0) {
            [self scrollToBottomMessage];
        }
    });
}

- (void)sortMessages {
    [self.messages sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                      ascending:YES]]];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    
    self.bottomConstraint.constant = keyboardHeight + 8;
    [self.view setNeedsLayout];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    [self scrollToBottomMessage];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.bottomConstraint.constant = 8;
    [self.view setNeedsLayout];
}

- (IBAction)viewTapped:(id)sender {
    [self.textField resignFirstResponder];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"
                                                            forIndexPath:indexPath];
    
    NSMutableDictionary *message = [self.messages objectAtIndex:indexPath.row];
    
    cell.detailTextLabel.text = [message objectForKey:@"author"];
    cell.textLabel.text = [message objectForKey:@"body"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
 
    if (textField.text.length == 0) {
        [self.view endEditing:YES];
    } else {
        
        [self.bridgeController sendMessageToTwilioWithText:textField.text];
        textField.text = @"";
        [textField resignFirstResponder];
        
    }
    
    return YES;
}

#pragma mark - BridgeDelegate

- (void)bridgeController:(HYPBridgeController *)bridgeController
          didSendMessage:(NSString *)response
{
    //Message Sent.
    
}

- (void)requestClient:(NSTimer *)timer
{
    [self requestOwnTwilioClient];
}

- (void)bridgeController:(HYPBridgeController *)bridgeController
          didJoinChannel:(HYPTwilioChannel *)channel
            withIdentity:(NSString *)identity
{
    
    
    HYPTwilioChannel * hypTwilioChannel = [[HYPTwilioChannel alloc] initWithTwilioChannel:channel.twilioChannel];
    self.channel = hypTwilioChannel;
    self.navigationItem.prompt = [NSString stringWithFormat:@"Logged in as %@",identity];
    self.netAccess = true;
    
}

- (void)bridgeController:(HYPBridgeController *)bridgeController
       didReceiveMessage:(NSMutableDictionary *)message
{
    
    [self addMessages:message];
    
}
- (void)bridgeController:(HYPBridgeController *)bridgeController
           didJoinTwilio:(NSMutableDictionary *)response
{
    
    self.navigationItem.prompt = [NSString stringWithFormat:@"Logged in offline as %@", [response objectForKey:@"identity"]];
    self.netAccess = false;
    
}

- (void) bridgeController:(HYPBridgeController *)bridgeController
           failConnecting:(NSString *)response
{
    
    self.netAccess = false;
    
}

- (void) bridgeController:(HYPBridgeController *)bridgeController
          didLoseInstance:(NSString *)response
{
    if ([response isEqualToString:@"off"]){
        self.navigationItem.prompt = [NSString stringWithFormat:@"Logging in..."];
        
    }
    
}

@end
