/*
 * This project constitutes a work of the United States Government and is
 * not subject to domestic copyright protection under 17 USC § 105.
 * 
 * However, because the project utilizes code licensed from contributors
 * and other third parties, it therefore is licensed under the MIT
 * License.  http://opensource.org/licenses/mit-license.php.  Under that
 * license, permission is granted free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the conditions that any appropriate copyright notices and this
 * permission notice are included in all copies or substantial portions
 * of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

//
//  WHSharingUtilities.m
//  WhiteHouseApp
//
//

#import "WHSharingUtilities.h"

#import "WHAppDelegate.h"
#import "WHFeedCache.h"

typedef enum {
    ArticleActionSafari,
    ArticleActionEmail,
    ArticleActionTweet,
    ArticleActionFavorite,
    ArticleActionFacebook
} ArticleActions;


/**
 * Defaults key for wether or not user has received instructions on how to share videos
 */
static NSString *WHVideoFavoriteInstructionsDefaultKey = @"VideoSharingInstructions";


@interface WHSharingUtilities ()
@property (nonatomic, strong) WHFeedItem *feedItem;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) NSArray *actions;
@end


@implementation WHSharingUtilities

@synthesize feedItem = _feedItem;
@synthesize viewController = _viewController;
@synthesize actions = _actions;

- (id)initWithViewController:(UIViewController *)viewController
{
    if ((self = [super init])) {
        self.viewController = viewController;
    }
    
    return self;
}


- (void)emailArticle
{
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
    mailer.mailComposeDelegate = self;
    NSString *title = self.feedItem.title;
    [mailer setSubject:title];
    NSString *body = [NSString stringWithFormat:@"<a href=\"%@\">%@</a> \n Brought you by <a href=\"http://alturl.com/knoj2\">TechBeat App</a>", [self.feedItem.link absoluteString], title];
    [mailer setMessageBody:body isHTML:YES];
    [self.viewController presentViewController:mailer animated:YES completion:nil];
}


//- (void)tweetArticle
//{
//    TWTweetComposeViewController *tweet = [[TWTweetComposeViewController alloc] init];
//    [tweet setInitialText:self.feedItem.title];
//    [tweet addURL:self.feedItem.link];
//    [self.viewController presentModalViewController:tweet animated:YES];
//}
//
//
//- (void)shareOnFacebook
//{
//    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
//        
//        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//        
//        [mySLComposerSheet setInitialText:self.feedItem.title];
//        
////        [mySLComposerSheet addImage:[UIImage imageNamed:@"myImage.png"]];
//        
//        [mySLComposerSheet addURL:self.feedItem.link];
//        
//        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
//            
//            switch (result) {
//                case SLComposeViewControllerResultCancelled:
//                    NSLog(@"Post Canceled");
//                    break;
//                case SLComposeViewControllerResultDone:
//                    NSLog(@"Post Sucessful");
//                    break;
//                    
//                default:
//                    break;
//            }
//        }];
//        
//        [self.viewController presentViewController:mySLComposerSheet animated:YES completion:nil];
//    }
//}

- (void)shareOn:(NSString *)service
{
//    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook] && [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
//    
        DebugLog(@"service available");
        SLComposeViewController *slComposerSheet = nil;
        if ([service isEqualToString:@"tweet"]){
            slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        } else if ([service isEqualToString:@"facebook"]){
            slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        }
        
        DebugLog(@"twitter or facebook available");
        NSString *title = [NSString stringWithFormat:@"%@ by TechBeat App http://alturl.com/knoj2",self.feedItem.title];
        [slComposerSheet setInitialText:title];
        
        //        [slComposerSheet addImage:[UIImage imageNamed:@"myImage.png"]];
        
        [slComposerSheet addURL:self.feedItem.link];
        
        [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    DebugLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    DebugLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self.viewController presentViewController:slComposerSheet animated:YES completion:nil];
        
//    }
    
    
    
}



#pragma mark - action sheet methods


/**
 * Create action items, create action sheet and present it
 */
- (void)share:(WHFeedItem *)item
{
    // store the feed item for callback/delegate methods
    self.feedItem = item;
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    NSMutableArray *actions = [NSMutableArray array];
    
    NSString *safariTitle = NSLocalizedString(@"ShareSafari", @"Title for safari button in sharing action sheet");
    [actions addObject:[NSNumber numberWithInt:ArticleActionSafari]];
    [sheet addButtonWithTitle:safariTitle];
    
    if ([MFMailComposeViewController canSendMail]) {
        NSString *mailTitle = NSLocalizedString(@"ShareEmail", @"Title for email button in sharing action sheet");
        [actions addObject:[NSNumber numberWithInt:ArticleActionEmail]];
        [sheet addButtonWithTitle:mailTitle];
    }
    
    NSString *tweetTitle = NSLocalizedString(@"ShareTwitter", @"Title for twitter button in sharing action sheet");
    [actions addObject:[NSNumber numberWithInt:ArticleActionTweet]];
    [sheet addButtonWithTitle:tweetTitle];
    
    NSString *facebook = NSLocalizedString(@"ShareFacebook", @"Title for facebook button in sharing action sheet");
    [actions addObject:[NSNumber numberWithInt:ArticleActionFacebook]];
    [sheet addButtonWithTitle:facebook];
    
//    NSString *favoriteTitle = NSLocalizedString(@"AddToFavorites", @"Title for favorites button in sharing action sheet");
//    [actions addObject:[NSNumber numberWithInt:ArticleActionFavorite]];
//    [sheet addButtonWithTitle:favoriteTitle];
    
    [sheet addButtonWithTitle:@"Cancel"];
    [sheet setCancelButtonIndex:actions.count];
    
    self.actions = actions;
    
    [sheet showInView:self.viewController.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    int actionID = [[self.actions objectAtIndex:buttonIndex] intValue];
    
    switch (actionID) {
        case ArticleActionSafari:
            [[UIApplication sharedApplication] openURL:self.feedItem.link];
            break;
            
        case ArticleActionEmail:
            [self emailArticle];
            break;
            
        case ArticleActionTweet:
            [self shareOn:@"tweet"];
//            [self tweetArticle];
            break;
            
        case ArticleActionFacebook:
            [self shareOn:@"facebook"];
//            [self shareOnFacebook];
            break;
            
        case ArticleActionFavorite:
            self.feedItem.isFavorited = YES;
            [[WHFeedCache sharedCache] saveFeedItem:self.feedItem];
            break;
            
        default:
            break;
    }
}

#pragma mark - mail delegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
//    [self.viewController dismissModalViewControllerAnimated:YES];
}


#pragma mark Class methods used by view controllers

+ (void)showVideoInstructions
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (NO == [defaults boolForKey:WHVideoFavoriteInstructionsDefaultKey]) {
        NSString *title = NSLocalizedString(@"VideoSharingInstructionsTitle", @"");
        NSString *message = NSLocalizedString(@"VideoSharingInstructions", @"");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        [defaults setBool:YES forKey:WHVideoFavoriteInstructionsDefaultKey];
    }
}


@end
