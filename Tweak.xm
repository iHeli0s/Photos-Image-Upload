#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#define kHeaderBoundary @"_FS_PIU"

@class PIU;
UIImage *image;
int buttonNumber;
BOOL show = NO;
BOOL addButton = YES;
BOOL buttonDismiss = NO;
static id mainView;

@interface PIU : NSObject <NSXMLParserDelegate> {
NSMutableData *responseData;
NSMutableArray *array;
	NSString *currentElement;
	MBProgressHUD *HUD;

	NSMutableDictionary * item;
	NSMutableString *imageLink, *donePage;
}
-(void)sendImage:(NSString *)filePath;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSMutableArray *array;
@property (nonatomic, retain) NSMutableString *imageLink, *donePage;
@property (nonatomic, retain) NSString *currentElement;
@property (nonatomic, retain) NSMutableDictionary * item;




@end

@implementation PIU
@synthesize imageLink, donePage, responseData, item, array, currentElement;
-(void)sendImage:(NSString *)filePath {
responseData = [[NSMutableData data] retain];

   NSURL *url = [NSURL URLWithString:@"http://www.imageshack.us/upload_api.php"];
   UIImage *image = [UIImage imageWithContentsOfFile:filePath];
	NSData *imageData = UIImageJPEGRepresentation(image, 90);
	NSString *apiKey = @"38ACDGJP6873b68cf45e8f368112528cfd07182f";
 NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req setHTTPMethod:@"POST"];
NSString *type = @"image/jpeg";
        NSString *multipartContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kHeaderBoundary];
        [req setValue:multipartContentType forHTTPHeaderField:@"Content-type"];
        
        //adding the body:
        NSMutableData *postBody = [NSMutableData data];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", kHeaderBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postBody appendData:[@"Content-Disposition: form-data; name=\"fileupload\"; filename=\"iPhoneImage\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", type] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:imageData];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", kHeaderBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postBody appendData:[@"Content-Disposition: form-data; name=\"key\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[apiKey dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", kHeaderBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
     
        
        [req setHTTPBody:postBody];
	HUD = [[MBProgressHUD alloc] initWithView:[mainView window]];
	[[mainView window] addSubview:HUD];

	HUD.delegate = nil;
	HUD.labelText = @"Uploading...";

	[HUD show:YES];
	[NSURLConnection connectionWithRequest:req delegate:self];


}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	HUD.labelText = @"Parsing Data";

    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	array = [[NSMutableArray alloc]init];
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:responseData ];
	[xmlParser setDelegate:self];
	    [xmlParser setShouldProcessNamespaces:NO];
    [xmlParser setShouldReportNamespacePrefixes:NO];
    [xmlParser setShouldResolveExternalEntities:NO];
    [xmlParser parse];
		    [responseData release];

}

 - (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
    //NSLog(@"found this element: %@", elementName);
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"links"]) {
		// clear out our story item caches...
		item = [[NSMutableDictionary alloc] init];
		imageLink = [[NSMutableString alloc] init];
		donePage = [[NSMutableString alloc] init];
			}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	//NSLog(@"ended element: %@", elementName);
	if ([elementName isEqualToString:@"links"]) {
		// save values to an item, then store that item into the array...
		[item setObject:imageLink forKey:@"imageLink"];
		[item setObject:donePage forKey:@"pageLink"];
		
		
		[array addObject:[item copy]];
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	//NSLog(@"found characters: %@", string);
	// save the characters for the current item...
	if ([currentElement isEqualToString:@"image_link"]) {
		[imageLink appendString:string];
	} else if ([currentElement isEqualToString:@"done_page"]) {
		[donePage appendString:string];
	}	
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]] autorelease];
	   HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = @"Image Uploaded!!";
	[HUD hide:YES afterDelay:2];
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	NSString *link = [[array objectAtIndex:0]objectForKey:@"imageLink"];
	link = [link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSURL *url = [NSURL URLWithString:link];
	pasteboard.URL = url;
[array release];
[item release];
[imageLink release];
[donePage release];
}



@end

%hook UIActionSheet

-(void)presentSheetInView:(id)view { 
if(addButton && self.numberOfButtons > 2) {
[self addButtonWithTitle:@"Upload"];
id button = [[self buttons] lastObject];
			[[self buttons] removeObject:button];			
		self.cancelButtonIndex = self.numberOfButtons;

			[[self buttons] insertObject:button atIndex:self.numberOfButtons - 1];
			buttonNumber = self.numberOfButtons - 1;
			buttonDismiss = YES;
			}

%orig;

}

%end
%hook PLPhotoBrowserController

- (void)viewDidAppear {

	mainView = [self view];
%orig;

}
- (void)_startSettingWallpaper:(id)arg1 {
addButton = NO;
%orig;

}
- (void)_endSettingWallpaper:(id)arg1 {
addButton = YES;
%orig;

}


- (void)actionSheet:(id)arg1 clickedButtonAtIndex:(int)arg2 {
%orig;
if(arg2 ==  buttonNumber && buttonDismiss) {
show = YES;
[self printCurrentPhoto:nil];

}
buttonDismiss = NO;
}
- (void)actionSheet:(id)arg1 didDismissWithButtonIndex:(int)arg2 {
%orig;

}

%end
%hook PLPhotoPrinter
- (void)printPhoto:(id)arg1 {
if(show) {
NSString *string = [NSString stringWithFormat:@"%@",arg1];
NSArray *lines = [string componentsSeparatedByString:@","];
NSString *finalString = [[lines objectAtIndex:2] stringByReplacingOccurrencesOfString:@"file=" withString:@""];
finalString = [NSString stringWithFormat:@"/var/mobile/Media/%@",finalString];
finalString = [finalString stringByReplacingOccurrencesOfString:@" " withString:@""];
PIU *control = [[PIU alloc]init];
[control sendImage:finalString];
[control release];
show = NO;
}
else {

%orig;
}
}



%end


