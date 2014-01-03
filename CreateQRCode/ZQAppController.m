//
//  ZQAppController.m
//  CreateQRCode
//
//  Created by Little Treasure on 7/30/13.
//  Copyright (c) 2013 Little_Treasure. All rights reserved.
//

#import "ZQAppController.h"
#import "ZQQRCodeViewController.h"
#import "QRCodeGenerator.h"

#define ImageEndIndentifier @"imageIndentifier"          //this indentifier is the number of the QRCode 
#define ImagePrefix @"LTQRCode"                         // the image's prefix name
#define SQLFilePath @"/Users/nick/Documents/VRCode"     // where the SQL command save
#define DBName @"littletreasure"                        // the datebase name in the SQL command
#define TableName @"ProductNumber"                      // the table name in the SQL command
#define NumberField @"SecurityNumber"                   // the field name in the SQL command
#define KeyField @"Key"                                 // the field name in the SQL command

#define TheRandomLength 76
#define KEYLENGTH 24

@interface ZQAppController ()
{
    NSNumberFormatter *numberFormatter;
    ImageFormat imageFormat;
    BOOL isWrite;
    BOOL isSave;
    dispatch_queue_t golbal;
    dispatch_queue_t mainQueue;
    NSOpenPanel *panel;
    NSFileHandle *fileHandle;
    NSData *sqlData;
    NSString *sqlFilePath;
    NSString *insertString;
    NSString *productStr; // this is the String of the product perfix indentifier which factory make this product
    // this array saved the chars to randomly generate the key
    NSArray *charArray;
    NSDictionary *productDic;
}
@property (weak) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSTextField *countField;
@property (weak) IBOutlet NSTextField *lengthField;
@property (weak) IBOutlet NSStepper *lengthStepper;
@property (weak) IBOutlet NSTextField *lengthLabel;
@property (weak) IBOutlet NSTextField *beginNumberField;
@property (weak) IBOutlet NSTextField *endNumberField;
@property (assign) GenerateWay theGenerateWay;
@property (strong) NSDateFormatter *dateFormatter;
@property (strong) NSString *dateString;
@property (weak) IBOutlet NSPopUpButton *imageFormatter;
@property (strong) NSString *filePath;
@property (weak) IBOutlet NSPopUpButton *imageFormatButton;
@property (weak) IBOutlet NSPopUpButton *areaUpButton;
@property (weak) IBOutlet NSPopUpButton *manuUpButton;
@property (weak) IBOutlet NSPopUpButton *cateUpButton;
@property (weak) IBOutlet NSPopUpButton *speUpButton;

@end

@implementation ZQAppController

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib
{
    if (![[ZQQRCodeViewController shareQRCodeController].view superview]) {
        [_codeView addSubview:[ZQQRCodeViewController shareQRCodeController].view];
    }
    [_textField resignFirstResponder];
    
    // observer the textField changed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:NSControlTextDidChangeNotification object:nil];
    golbal = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    mainQueue = dispatch_get_main_queue();
    isWrite = NO;
    isSave = NO;
    
    productDic = [self getTheProductDic];
    
    [self createSQLFileFloder];
    [self initDateFormatter];
    [self initCharArray];
}

- (void)initCharArray
{
    NSString *string = @"a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,"
                        "1,2,3,4,5,6,7,8,9,0,"
                        "#,$,%,*,),(,_,+,=,-,},{,],[,"
                        "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z";
    charArray = [string componentsSeparatedByString:@","];
}

- (void)initDateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"YYYYMMddHHmmssSSSS"];
    }
}

- (void)createSQLFileFloder
{
    BOOL isTrue = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:SQLFilePath isDirectory:&isTrue]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:SQLFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

// when the text changed the code view will changed too
- (void)textChanged:(NSNotification *)notification
{
    if (notification.object == _textField) {
        if (![_textField.stringValue isEqualToString:@""]) {
            NSString *keyString = [self generateTheEncryptKey];
            NSString *eString = [NSString encryptString:_textField.stringValue withKey:keyString];
            [[ZQQRCodeViewController shareQRCodeController] setEncodeString:eString];
            [[ZQQRCodeViewController shareQRCodeController] showQRCodeView];
        } else {
            [[ZQQRCodeViewController shareQRCodeController].imageView setImage:nil];
            [[ZQQRCodeViewController shareQRCodeController] setEncodeString:@""];
        }
    } else if (notification.object == _beginNumberField) {
        if (![_beginNumberField.stringValue isEqualToString:@""]) {
            [_endNumberField setStringValue:[self formatterNumber:[NSNumber numberWithInt:_beginNumberField.intValue + _countField.intValue - 1] withString:_beginNumberField.stringValue]];
        } else {
            [_endNumberField setStringValue:@""];
        }
        if (_countField.intValue == 1) {
            [_endNumberField setStringValue:[self formatterNumber:[NSNumber numberWithInt:[_beginNumberField intValue]] withString:[_beginNumberField stringValue]]];
        }
    } else if (notification.object == _countField) {
        if ([_beginNumberField isEnabled] && ![_beginNumberField.stringValue isEqualToString:@""]) {
            [_endNumberField setStringValue:[self formatterNumber:[NSNumber numberWithInt:_beginNumberField.intValue + _countField.intValue - 1] withString:_beginNumberField.stringValue]];
        }
    }
}

// select the generate way to make the QRCode
- (IBAction)selectGenerateWay:(NSMatrix *)sender {
    if ([sender selectedRow] == 0) {
        [_lengthField setEnabled:YES];
        [_lengthStepper setEnabled:YES];
        [_lengthField setEnabled:YES];
        [_beginNumberField setEnabled:![_lengthField isEnabled]];
        [_endNumberField setEnabled:![_lengthField isEnabled]];
        [_beginNumberField setStringValue:@""];
        [_endNumberField setStringValue:@""];
        _theGenerateWay = randomly;
    } else {
        [_endNumberField setEnabled:YES];
        [_beginNumberField setEnabled:[_endNumberField isEnabled]];
        [_lengthField setEnabled:![_endNumberField isEnabled]];
        [_lengthLabel setEnabled:![_endNumberField isEnabled]];
        [_lengthStepper setEnabled:![_endNumberField isEnabled]];
        _theGenerateWay = rules;
    }
}

- (void)createSecurityNumberWith:(GenerateWay)way
{
    if(isSave) {
        sqlFilePath = [self createSQLFile];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:sqlFilePath];
    }
    if (way == randomly) {
        _dateString = [_dateFormatter stringFromDate:[NSDate date]];
        long date = [_dateString longLongValue];
        srand((unsigned)date);
        int length = [_lengthField intValue];
        int count = [_countField intValue];
        
        NSMutableString *numberString = [NSMutableString new];
        for (int i = 0; i < count; i++) {
            for (int j = 0; j < length; j++) {
                int randomNumber = random() % 10;
                [numberString appendString:[NSString stringWithFormat:@"%i", randomNumber]];
            }
            [self createQRCodeWithString:numberString];
            [numberString deleteCharactersInRange:NSMakeRange(0, numberString.length)];
        }
        numberString = nil;
    } else {
        NSString *numberString = nil;
        for (long i = _beginNumberField.intValue; i <= _endNumberField.intValue; i ++) {
            numberString = [self formatterNumber:[NSNumber numberWithLong:i] withString:_beginNumberField.stringValue];
            [self createQRCodeWithString:numberString];
        }
    }
}

- (void)createQRCodeWithString:(NSString *)string
{
    NSString *finalString = [NSString stringWithFormat:@"%@%@", productStr, string];
    NSString *keyString = [self generateTheEncryptKey];
    NSString *encryptString = [NSString encryptString:finalString withKey:keyString];
    NSString *encodeString = [NSString stringWithFormat:@"LT %@", encryptString];
    [[ZQQRCodeViewController shareQRCodeController] setEncodeString:encodeString];
    NSImage *image = [[ZQQRCodeViewController shareQRCodeController] createQRCodeImageWithString:encodeString];
    if (image) {
        if (isSave) {
            insertString = [NSString stringWithFormat:@"INSERT INTO `%@`.`%@` (`%@`, `%@`) VALUES ('%@', '%@');\n", DBName, TableName, NumberField, KeyField, encryptString, keyString];
            sqlData = [insertString dataUsingEncoding:NSUTF8StringEncoding];
            [self saveData:sqlData withHandle:fileHandle];
        }
        dispatch_async(mainQueue, ^{
            [[ZQQRCodeViewController shareQRCodeController].imageView setImage:image];
        });
    }
    
    if (_filePath && isWrite && image) {
        [self writeImage:image imageFormat:imageFormat];
    }
    
    keyString = nil;
    encryptString = nil;
    image = nil;
    finalString = nil;
    encodeString = nil;
}

- (NSString *)formatterNumber:(NSNumber *)number withString:(NSString *)string
{
    if (!numberFormatter) {
        numberFormatter = [[NSNumberFormatter alloc] init];
    }
    [numberFormatter setFormat:string];
    return [numberFormatter stringFromNumber:number];
}

- (IBAction)printQRCode:(NSButton *)sender {
    [_textField setStringValue:@""];
    productStr = [self generateTheProductString];
    if (!productStr) {
        return;
    }
    dispatch_async(golbal, ^{
        [self createSecurityNumberWith:_theGenerateWay];
    });
}
- (IBAction)writeImageToFile:(NSButton *)sender {
    [_imageFormatter setEnabled:sender.state];
    isWrite = sender.state;
    if (sender.state == YES) {
        imageFormat = (ImageFormat)_imageFormatButton.indexOfSelectedItem;
        if (!panel) {
            panel = [NSOpenPanel openPanel];
        }
        [panel setPrompt:@"Select"];
        [panel setTitle:@"Select a folder to save the generate QRCode"];
        [panel setCanChooseFiles:NO];
        [panel setCanChooseDirectories:YES];
        [panel setCanCreateDirectories:YES];
        
            if ([panel runModal] == NSOKButton) {
                _filePath = [[panel filenames] objectAtIndex:0];
                isWrite = YES;
                NSLog(@"select path : %@", _filePath);
            } else {
                sender.state = NO;
                _filePath = nil;
                isWrite = NO;
                [_imageFormatter setEnabled:NO];
            }
    }
}

- (IBAction)createSQLFile:(NSButton *)sender {
    isSave = sender.state;
}

- (IBAction)selectImageFormat:(NSPopUpButton *)sender {
    switch (sender.indexOfSelectedItem) {
        case 0:
            imageFormat = PngImage;
            break;
        case 1:
            imageFormat = JpegImage;
            break;
        default:
            break;
    }
}

- (void)writeImage:(NSImage *)image imageFormat:(ImageFormat)format
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [image TIFFRepresentation];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:data];
        NSDictionary *imageProp = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
        if (format == PngImage) {
            data = [imageRep representationUsingType:NSPNGFileType properties:imageProp];
        } else {
            data = [imageRep representationUsingType:NSJPEGFileType properties:imageProp];
        }
        [data writeToFile:[self fileNameWithImageFormat:format] atomically:NO];
//    });
}

- (NSString *)fileNameWithImageFormat:(ImageFormat)format
{
    NSString *suffix = nil;
    switch (format) {
        case PngImage:
            suffix = @".PNG";
            break;
        case JpegImage:
            suffix = @".JPEG";
            break;
        default:
            break;
    }
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:ImageEndIndentifier];
    if (!number) {
        number = @0;
    }
    long theId = [number longValue];
    number = [NSNumber numberWithLong:theId + 1];
    [[NSUserDefaults standardUserDefaults] setObject:number forKey:ImageEndIndentifier];
    
    NSString *string = [NSString stringWithFormat:@"%@%ld%@", ImagePrefix, theId, suffix];
    NSString *theFilePath = [_filePath stringByAppendingPathComponent:string];
    return theFilePath;
}

- (NSString *)generateTheEncryptKey
{
    NSString *dateOfString = [_dateFormatter stringFromDate:[NSDate date]];
    long date = [dateOfString longLongValue];
    srand((unsigned)date);
    NSMutableString *keyString = [NSMutableString stringWithCapacity:24];
    for (int i = 0; i<KEYLENGTH; i++) {
        int randomNumber = rand() % TheRandomLength;
        [keyString appendString:[charArray objectAtIndex:randomNumber]];
    }
    NSString *ruturnString = [keyString copy];
    keyString = nil;
    return ruturnString;
}

- (NSString *)createSQLFile
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYMMdd_HHmmss"];
    NSString *file = [NSString stringWithFormat:@"SQLCommand%@.sql", [dateFormatter stringFromDate:[NSDate date]]];
    NSString *fullFilePath = [SQLFilePath stringByAppendingPathComponent:file];
    dateFormatter = nil;
    file = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:fullFilePath contents:nil attributes:nil];
    }
    
    return fullFilePath;
}

- (void)saveData:(NSData *)data withHandle:(NSFileHandle *)handle
{
    [handle seekToEndOfFile];
    [handle writeData:data];
}

- (NSDictionary *)getTheProductDic
{
//    if (![[NSFileManager defaultManager] fileExistsAtPath:[[NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"CreateQRCode/Product.plist"]]) {
//        [[NSFileManager defaultManager] createFileAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"CreateQRCode/Product.plist"] contents:nil attributes:nil];
//        
//        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"Product" ofType:@"plist"] toPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"CreateQRCode/Product.plist"] error:nil];
//    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Product" ofType:@"plist"]];
    [_areaUpButton addItemsWithTitles:[[dic objectForKey:@"Area"] allKeys]];
    [_manuUpButton addItemsWithTitles:[[dic objectForKey:@"Manufacturer"] allKeys]];
    [_cateUpButton addItemsWithTitles:[[dic objectForKey:@"Category"] allKeys]];
    [_speUpButton addItemsWithTitles:[[dic objectForKey:@"Specification"] allKeys]];
    
    return dic;
}

- (NSString *)generateTheProductString
{
    NSString *one = [[productDic objectForKey:@"Area"] objectForKey:_areaUpButton.selectedItem.title];
    NSString *two = [[productDic objectForKey:@"Manufacturer"] objectForKey:_manuUpButton.selectedItem.title];
    NSString *three = [[productDic objectForKey:@"Category"] objectForKey:_cateUpButton.selectedItem.title];
    NSString *four = [[productDic objectForKey:@"Specification"] objectForKey:_speUpButton.selectedItem.title];
    
    if (one && two && three && four) {
        NSString *returnString = [NSString  stringWithFormat:@"%@%@%@%@", one, two, three, four];
        return returnString;
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Warning!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please select a product!"];
        [alert runModal];
        alert = nil;
        NSBeep();
        return nil;
    }
    
    one = nil;
    two = nil;
    three = nil;
    four = nil;
    
}

- (void)dealloc
{
    numberFormatter = nil;
    _dateFormatter = nil;
    _dateString = nil;
    _filePath = nil;
}

@end
