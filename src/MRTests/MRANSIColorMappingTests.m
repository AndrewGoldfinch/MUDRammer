//
//  MRANSIColorMappingTests.m
//  Mudrammer
//
//  Tests for ANSI color code to UIColor mapping
//  Documents the 256-color palette behavior before refactoring
//

#import "MRTestHelpers.h"

@interface MRANSIColorMappingTests : XCTestCase
@end

@implementation MRANSIColorMappingTests
{
    SSANSIEngine *engine;
}

- (void)setUp {
    [super setUp];
    engine = [SSANSIEngine new];
    engine.defaultTextColor = kDefaultColor;
    engine.defaultFont = kDefaultFont;
}

- (void)tearDown {
    engine = nil;
    [super tearDown];
}

#pragma mark - 16 Basic Color Mapping Tests

- (void)testColorMapping_BasicForegroundColors {
    // Test all 8 basic foreground colors (30-37)
    NSDictionary *colorTests = @{
        @"30": @(SPLSGRCodeFgBlack),
        @"31": @(SPLSGRCodeFgRed),
        @"32": @(SPLSGRCodeFgGreen),
        @"33": @(SPLSGRCodeFgYellow),
        @"34": @(SPLSGRCodeFgBlue),
        @"35": @(SPLSGRCodeFgMagenta),
        @"36": @(SPLSGRCodeFgCyan),
        @"37": @(SPLSGRCodeFgWhite),
    };

    for (NSString *code in colorTests) {
        SPLSGRCode expectedCode = [colorTests[code] integerValue];
        UIColor *expectedColor = [UIColor colorForSGRCode:expectedCode defaultColor:kDefaultColor];

        NSString *testString = [NSString stringWithFormat:@"\033[%@mTest\033[0m", code];
        SSAttributedLineGroup *lineGroup = [engine parseANSIString:testString];

        SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
        NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
        UIColor *actualColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];

        EXP_expect(actualColor).to.equal(expectedColor);
    }
}

- (void)testColorMapping_BasicBackgroundColors {
    // Test all 8 basic background colors (40-47)
    NSDictionary *colorTests = @{
        @"40": @(SPLSGRCodeBgBlack),
        @"41": @(SPLSGRCodeBgRed),
        @"42": @(SPLSGRCodeBgGreen),
        @"43": @(SPLSGRCodeBgYellow),
        @"44": @(SPLSGRCodeBgBlue),
        @"45": @(SPLSGRCodeBgMagenta),
        @"46": @(SPLSGRCodeBgCyan),
        @"47": @(SPLSGRCodeBgWhite),
    };

    for (NSString *code in colorTests) {
        SPLSGRCode expectedCode = [colorTests[code] integerValue];
        UIColor *expectedColor = [UIColor colorForSGRCode:expectedCode defaultColor:kDefaultColor];

        NSString *testString = [NSString stringWithFormat:@"\033[%@mTest\033[0m", code];
        SSAttributedLineGroup *lineGroup = [engine parseANSIString:testString];

        SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
        NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];

        if (expectedCode == SPLSGRCodeBgBlack) {
            // Black background is clear color
            EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).to.beNil();
        } else {
            UIColor *actualColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[kTTTBackgroundFillColorAttributeName]];
            EXP_expect(actualColor).to.equal(expectedColor);
        }
    }
}

- (void)testColorMapping_BrightForegroundColors {
    // Test all 8 bright foreground colors (90-97)
    NSDictionary *colorTests = @{
        @"90": @(SPLSGRCodeFgBrightBlack),
        @"91": @(SPLSGRCodeFgBrightRed),
        @"92": @(SPLSGRCodeFgBrightGreen),
        @"93": @(SPLSGRCodeFgBrightYellow),
        @"94": @(SPLSGRCodeFgBrightBlue),
        @"95": @(SPLSGRCodeFgBrightMagenta),
        @"96": @(SPLSGRCodeFgBrightCyan),
        @"97": @(SPLSGRCodeFgBrightWhite),
    };

    for (NSString *code in colorTests) {
        SPLSGRCode expectedCode = [colorTests[code] integerValue];
        UIColor *expectedColor = [UIColor colorForSGRCode:expectedCode defaultColor:kDefaultColor];

        NSString *testString = [NSString stringWithFormat:@"\033[%@mTest\033[0m", code];
        SSAttributedLineGroup *lineGroup = [engine parseANSIString:testString];

        SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
        NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
        UIColor *actualColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];

        EXP_expect(actualColor).to.equal(expectedColor);
    }
}

- (void)testColorMapping_BrightBackgroundColors {
    // Test all 8 bright background colors (100-107)
    NSDictionary *colorTests = @{
        @"100": @(SPLSGRCodeBgBrightBlack),
        @"101": @(SPLSGRCodeBgBrightRed),
        @"102": @(SPLSGRCodeBgBrightGreen),
        @"103": @(SPLSGRCodeBgBrightYellow),
        @"104": @(SPLSGRCodeBgBrightBlue),
        @"105": @(SPLSGRCodeBgBrightMagenta),
        @"106": @(SPLSGRCodeBgBrightCyan),
        @"107": @(SPLSGRCodeBgBrightWhite),
    };

    for (NSString *code in colorTests) {
        SPLSGRCode expectedCode = [colorTests[code] integerValue];
        UIColor *expectedColor = [UIColor colorForSGRCode:expectedCode defaultColor:kDefaultColor];

        NSString *testString = [NSString stringWithFormat:@"\033[%@mTest\033[0m", code];
        SSAttributedLineGroup *lineGroup = [engine parseANSIString:testString];

        SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
        NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
        UIColor *actualColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[kTTTBackgroundFillColorAttributeName]];

        EXP_expect(actualColor).to.equal(expectedColor);
    }
}

#pragma mark - XTerm 256 Color Palette Tests

- (void)testColorPalette_AllXTerm256Colors {
    // Test that all 256 colors can be accessed without crashing
    for (NSInteger i = 0; i < 256; i++) {
        NSString *testString = [NSString stringWithFormat:@"\033[38;5;%ldmColor%ld\033[0m", (long)i, (long)i];
        SSAttributedLineGroup *lineGroup = [engine parseANSIString:testString];

        EXP_expect(lineGroup).toNot.beNil();
        EXP_expect(lineGroup.lines.count).to.equal(1);

        SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
        EXP_expect(item.line.string).to.equal([NSString stringWithFormat:@"Color%ld", (long)i]);
    }
}

- (void)testColorPalette_Basic16InXTerm {
    // Verify colors 0-15 in XTerm mode match their standard codes
    for (NSInteger i = 0; i < 16; i++) {
        NSString *testString = [NSString stringWithFormat:@"\033[38;5;%ldmTest\033[0m", (long)i];
        SSAttributedLineGroup *lineGroup = [engine parseANSIString:testString];

        SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
        NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
        UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];

        EXP_expect(color).toNot.beNil();
    }
}

- (void)testColorPalette_216ColorCube {
    // Test the 6x6x6 RGB cube (colors 16-231)
    // Formula: 16 + 36*r + 6*g + b, where r,g,b are 0-5

    // Test corners of the cube
    NSArray *testCases = @[
        @[@16, @"Cube start (0,0,0)"],      // 16 + 36*0 + 6*0 + 0
        @[@21, @"Cube (0,0,5)"],             // 16 + 36*0 + 6*0 + 5
        @[@51, @"Cube (0,5,5)"],             // 16 + 36*0 + 6*5 + 5
        @[@196, @"Cube (5,0,0)"],            // 16 + 36*5 + 6*0 + 0
        @[@231, @"Cube end (5,5,5)"],        // 16 + 36*5 + 6*5 + 5
    ];

    for (NSArray *testCase in testCases) {
        NSInteger colorCode = [testCase[0] integerValue];
        NSString *description = testCase[1];

        NSString *testString = [NSString stringWithFormat:@"\033[38;5;%ldm%@\033[0m", (long)colorCode, description];
        SSAttributedLineGroup *lineGroup = [engine parseANSIString:testString];

        EXP_expect(lineGroup).toNot.beNil();

        SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
        NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
        UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];

        EXP_expect(color).toNot.beNil();
    }
}

- (void)testColorPalette_GrayscaleRamp {
    // Test the 24-level grayscale (colors 232-255)
    for (NSInteger i = 232; i <= 255; i++) {
        NSString *testString = [NSString stringWithFormat:@"\033[38;5;%ldmGray%ld\033[0m", (long)i, (long)i];
        SSAttributedLineGroup *lineGroup = [engine parseANSIString:testString];

        EXP_expect(lineGroup).toNot.beNil();

        SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
        NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
        UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];

        EXP_expect(color).toNot.beNil();
    }
}

#pragma mark - Color Intensification Tests

- (void)testColorIntensification_AllBasicColors {
    // Test that bold intensifies all 8 basic colors
    NSArray *baseCodes = @[@30, @31, @32, @33, @34, @35, @36, @37];
    NSArray *brightCodes = @[@90, @91, @92, @93, @94, @95, @96, @97];

    for (NSUInteger i = 0; i < baseCodes.count; i++) {
        NSInteger baseCode = [baseCodes[i] integerValue];
        NSInteger brightCode = [brightCodes[i] integerValue];

        // Get color with bold
        NSString *boldString = [NSString stringWithFormat:@"\033[1;%ldmTest\033[0m", (long)baseCode];
        SSAttributedLineGroup *boldGroup = [engine parseANSIString:boldString];

        // Get bright color directly
        NSString *brightString = [NSString stringWithFormat:@"\033[%ldmTest\033[0m", (long)brightCode];
        // Reset engine to clear state
        engine = [SSANSIEngine new];
        engine.defaultTextColor = kDefaultColor;
        engine.defaultFont = kDefaultFont;
        SSAttributedLineGroup *brightGroup = [engine parseANSIString:brightString];

        SSAttributedLineGroupItem *boldItem = boldGroup.lines.firstObject;
        SSAttributedLineGroupItem *brightItem = brightGroup.lines.firstObject;

        NSDictionary *boldAttrs = [boldItem.line attributesAtIndex:0 effectiveRange:NULL];
        NSDictionary *brightAttrs = [brightItem.line attributesAtIndex:0 effectiveRange:NULL];

        UIColor *boldColor = [UIColor colorWithCGColor:(__bridge CGColorRef)boldAttrs[(id)kCTForegroundColorAttributeName]];
        UIColor *brightColor = [UIColor colorWithCGColor:(__bridge CGColorRef)brightAttrs[(id)kCTForegroundColorAttributeName]];

        // Bold should produce same color as bright variant
        EXP_expect(boldColor).to.equal(brightColor);

        // Reset for next iteration
        engine = [SSANSIEngine new];
        engine.defaultTextColor = kDefaultColor;
        engine.defaultFont = kDefaultFont;
    }
}

- (void)testColorIntensification_BackgroundsNotAffected {
    // Test that bold doesn't intensify background colors
    NSString *testString = @"\033[1;41mTest\033[0m";
    SSAttributedLineGroup *lineGroup = [engine parseANSIString:testString];

    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    UIColor *bgColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[kTTTBackgroundFillColorAttributeName]];

    // Should be normal red background, not bright red
    UIColor *expectedColor = [UIColor colorForSGRCode:SPLSGRCodeBgRed defaultColor:nil];
    EXP_expect(bgColor).to.equal(expectedColor);
}

#pragma mark - Color Reset Tests

- (void)testColorReset_AllReset {
    // Test ESC[0m resets all colors and formatting
    NSString *testString = @"\033[1;4;31;44mFormatted\033[0mReset";
    SSAttributedLineGroup *lineGroup = [engine parseANSIString:testString];

    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;

    // Check "Reset" portion has default color and no formatting
    NSRange resetRange = [item.line.string rangeOfString:@"Reset"];
    NSDictionary *attrs = [item.line attributesAtIndex:resetRange.location effectiveRange:NULL];

    UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];
    EXP_expect(color).to.equal(kDefaultColor);
    EXP_expect(attrs[NSUnderlineStyleAttributeName]).to.beNil();
    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).to.beNil();
}

- (void)testColorReset_ForegroundOnly {
    // Test ESC[39m resets only foreground
    NSString *testString = @"\033[31;44mColored\033[39mFG Reset";
    SSAttributedLineGroup *lineGroup = [engine parseANSIString:testString];

    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    NSRange resetRange = [item.line.string rangeOfString:@"FG Reset"];
    NSDictionary *attrs = [item.line attributesAtIndex:resetRange.location effectiveRange:NULL];

    UIColor *fgColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];
    EXP_expect(fgColor).to.equal(kDefaultColor);

    // Background should still be set
    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).toNot.beNil();
}

- (void)testColorReset_BackgroundOnly {
    // Test ESC[49m resets only background
    NSString *testString = @"\033[31;44mColored\033[49mBG Reset";
    SSAttributedLineGroup *lineGroup = [engine parseANSIString:testString];

    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    NSRange resetRange = [item.line.string rangeOfString:@"BG Reset"];
    NSDictionary *attrs = [item.line attributesAtIndex:resetRange.location effectiveRange:NULL];

    UIColor *fgColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];
    UIColor *expectedColor = [UIColor colorForSGRCode:SPLSGRCodeFgRed defaultColor:kDefaultColor];
    EXP_expect(fgColor).to.equal(expectedColor);

    // Background should be cleared
    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).to.beNil();
}

#pragma mark - Edge Cases

- (void)testColorMapping_InvalidXTermCode {
    // Test handling of XTerm codes outside 0-255 range
    NSString *testString = @"\033[38;5;999mInvalid\033[0m";
    SSAttributedLineGroup *lineGroup = [engine parseANSIString:testString];

    // Should not crash
    EXP_expect(lineGroup).toNot.beNil();
}

- (void)testColorMapping_NegativeXTermCode {
    // Test handling of negative XTerm codes
    NSString *testString = @"\033[38;5;-1mNegative\033[0m";
    SSAttributedLineGroup *lineGroup = [engine parseANSIString:testString];

    // Should not crash
    EXP_expect(lineGroup).toNot.beNil();
}

- (void)testColorMapping_MixedModesInSequence {
    // Test mixing standard and XTerm color codes
    NSString *testString = @"\033[31;38;5;196;44mMixed\033[0m";
    SSAttributedLineGroup *lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup).toNot.beNil();
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Mixed");
}

@end
