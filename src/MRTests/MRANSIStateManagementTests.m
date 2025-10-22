//
//  MRANSIStateManagementTests.m
//  Mudrammer
//
//  Tests for ANSI engine state management across multiple parse calls
//  Documents how state persists and resets before refactoring
//

#import "MRTestHelpers.h"

@interface MRANSIStateManagementTests : XCTestCase
@end

@implementation MRANSIStateManagementTests
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

#pragma mark - Foreground Color State

- (void)testState_ForegroundPersistsAcrossCalls {
    // Set foreground to red
    SSAttributedLineGroup *group1 = [engine parseANSIString:@"\033[31mRed"];

    // Next call should maintain red color
    SSAttributedLineGroup *group2 = [engine parseANSIString:@"Still Red"];

    SSAttributedLineGroupItem *item1 = group1.lines.firstObject;
    SSAttributedLineGroupItem *item2 = group2.lines.firstObject;

    NSDictionary *attrs1 = [item1.line attributesAtIndex:0 effectiveRange:NULL];
    NSDictionary *attrs2 = [item2.line attributesAtIndex:0 effectiveRange:NULL];

    UIColor *color1 = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs1[(id)kCTForegroundColorAttributeName]];
    UIColor *color2 = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs2[(id)kCTForegroundColorAttributeName]];

    EXP_expect(color1).to.equal(color2);
    EXP_expect(color1).to.equal([UIColor colorForSGRCode:SPLSGRCodeFgRed defaultColor:kDefaultColor]);
}

- (void)testState_ForegroundChangePersists {
    // Red, then green, then no code
    [engine parseANSIString:@"\033[31mRed"];
    [engine parseANSIString:@"\033[32mGreen"];

    SSAttributedLineGroup *group = [engine parseANSIString:@"No Code"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];

    UIColor *expectedColor = [UIColor colorForSGRCode:SPLSGRCodeFgGreen defaultColor:kDefaultColor];
    EXP_expect(color).to.equal(expectedColor);
}

- (void)testState_ForegroundResetClearsState {
    // Set red, then reset
    [engine parseANSIString:@"\033[31mRed\033[39m"];

    SSAttributedLineGroup *group = [engine parseANSIString:@"After Reset"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];

    EXP_expect(color).to.equal(kDefaultColor);
}

- (void)testState_AllResetClearsForeground {
    // Set red, then full reset
    [engine parseANSIString:@"\033[31mRed\033[0m"];

    SSAttributedLineGroup *group = [engine parseANSIString:@"After Reset"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];

    EXP_expect(color).to.equal(kDefaultColor);
}

#pragma mark - Background Color State

- (void)testState_BackgroundPersistsAcrossCalls {
    // Set background to blue
    [engine parseANSIString:@"\033[44mBlue BG"];

    // Next call should maintain blue background
    SSAttributedLineGroup *group = [engine parseANSIString:@"Still Blue BG"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];

    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).toNot.beNil();

    UIColor *bgColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[kTTTBackgroundFillColorAttributeName]];
    UIColor *expectedColor = [UIColor colorForSGRCode:SPLSGRCodeBgBlue defaultColor:nil];

    EXP_expect(bgColor).to.equal(expectedColor);
}

- (void)testState_BackgroundChangePersists {
    // Blue BG, then red BG, then no code
    [engine parseANSIString:@"\033[44mBlue BG"];
    [engine parseANSIString:@"\033[41mRed BG"];

    SSAttributedLineGroup *group = [engine parseANSIString:@"No Code"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];

    UIColor *bgColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[kTTTBackgroundFillColorAttributeName]];
    UIColor *expectedColor = [UIColor colorForSGRCode:SPLSGRCodeBgRed defaultColor:nil];

    EXP_expect(bgColor).to.equal(expectedColor);
}

- (void)testState_BackgroundResetClearsState {
    // Set blue BG, then reset background
    [engine parseANSIString:@"\033[44mBlue BG\033[49m"];

    SSAttributedLineGroup *group = [engine parseANSIString:@"After Reset"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];

    // Background should be cleared (nil or clear color)
    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).to.beNil();
}

- (void)testState_AllResetClearsBackground {
    // Set blue BG, then full reset
    [engine parseANSIString:@"\033[44mBlue BG\033[0m"];

    SSAttributedLineGroup *group = [engine parseANSIString:@"After Reset"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];

    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).to.beNil();
}

#pragma mark - Formatting State

- (void)testState_UnderlineDoesNotPersist {
    // Underline, then reset, then check persistence
    [engine parseANSIString:@"\033[4mUnderline\033[0m"];

    SSAttributedLineGroup *group = [engine parseANSIString:@"No Underline"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];

    // Underline should not persist after reset
    EXP_expect(attrs[NSUnderlineStyleAttributeName]).to.beNil();
}

- (void)testState_StrikethroughDoesNotPersist {
    // Strikethrough, then reset, then check
    [engine parseANSIString:@"\033[9mStrike\033[0m"];

    SSAttributedLineGroup *group = [engine parseANSIString:@"No Strike"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];

    EXP_expect(attrs[kTTTStrikeOutAttributeName]).to.beNil();
}

#pragma mark - Combined State

- (void)testState_ForegroundAndBackgroundBothPersist {
    // Set both foreground and background
    [engine parseANSIString:@"\033[31;44mRed on Blue"];

    // Check both persist
    SSAttributedLineGroup *group = [engine parseANSIString:@"Still Red on Blue"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];

    UIColor *fgColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];
    UIColor *bgColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[kTTTBackgroundFillColorAttributeName]];

    UIColor *expectedFg = [UIColor colorForSGRCode:SPLSGRCodeFgRed defaultColor:kDefaultColor];
    UIColor *expectedBg = [UIColor colorForSGRCode:SPLSGRCodeBgBlue defaultColor:nil];

    EXP_expect(fgColor).to.equal(expectedFg);
    EXP_expect(bgColor).to.equal(expectedBg);
}

- (void)testState_PartialResetPreservesOtherColors {
    // Set both colors, reset only foreground
    [engine parseANSIString:@"\033[31;44mRed on Blue\033[39m"];

    // Foreground should be default, background should persist
    SSAttributedLineGroup *group = [engine parseANSIString:@"Default on Blue"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];

    UIColor *fgColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];
    UIColor *bgColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[kTTTBackgroundFillColorAttributeName]];

    UIColor *expectedBg = [UIColor colorForSGRCode:SPLSGRCodeBgBlue defaultColor:nil];

    EXP_expect(fgColor).to.equal(kDefaultColor);
    EXP_expect(bgColor).to.equal(expectedBg);
}

#pragma mark - XTerm 256 State

- (void)testState_XTerm256ForegroundPersists {
    // Set XTerm foreground color
    [engine parseANSIString:@"\033[38;5;196mBright Red"];

    // Should persist to next call
    SSAttributedLineGroup *group = [engine parseANSIString:@"Still Bright Red"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];

    UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];
    EXP_expect(color).toNot.beNil();
    EXP_expect(color).toNot.equal(kDefaultColor);
}

- (void)testState_XTerm256BackgroundPersists {
    // Set XTerm background color
    [engine parseANSIString:@"\033[48;5;21mDark Blue BG"];

    // Should persist to next call
    SSAttributedLineGroup *group = [engine parseANSIString:@"Still Dark Blue BG"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];

    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).toNot.beNil();
}

- (void)testState_XTerm256ResetWorks {
    // Set XTerm color, then reset
    [engine parseANSIString:@"\033[38;5;196mBright Red\033[0m"];

    // Should be default
    SSAttributedLineGroup *group = [engine parseANSIString:@"Default"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];

    EXP_expect(color).to.equal(kDefaultColor);
}

#pragma mark - Bold State

- (void)testState_BoldStateDoesNotPersistAfterReset {
    // Set bold and color, then reset
    [engine parseANSIString:@"\033[1;31mBold Red\033[0m"];

    // Next red should not be bold
    SSAttributedLineGroup *group = [engine parseANSIString:@"\033[31mNormal Red"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];

    // Should be normal red, not bright red
    UIColor *expectedColor = [UIColor colorForSGRCode:SPLSGRCodeFgRed defaultColor:kDefaultColor];
    EXP_expect(color).to.equal(expectedColor);
}

- (void)testState_BoldStateAffectsSubsequentColors {
    // Set bold first
    [engine parseANSIString:@"\033[1mBold"];

    // Then set a color - should be intensified
    SSAttributedLineGroup *group = [engine parseANSIString:@"\033[31mBold Red"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];

    // Should be bright red due to prior bold
    UIColor *expectedColor = [UIColor colorForSGRCode:SPLSGRCodeFgBrightRed defaultColor:kDefaultColor];
    EXP_expect(color).to.equal(expectedColor);
}

#pragma mark - Multiple Engine Instances

- (void)testState_SeparateEnginesHaveSeparateState {
    // Create two engines
    SSANSIEngine *engine1 = [SSANSIEngine new];
    engine1.defaultTextColor = kDefaultColor;
    engine1.defaultFont = kDefaultFont;

    SSANSIEngine *engine2 = [SSANSIEngine new];
    engine2.defaultTextColor = kDefaultColor;
    engine2.defaultFont = kDefaultFont;

    // Set different colors in each
    [engine1 parseANSIString:@"\033[31mRed"];
    [engine2 parseANSIString:@"\033[32mGreen"];

    // Each should maintain its own color
    SSAttributedLineGroup *group1 = [engine1 parseANSIString:@"Text1"];
    SSAttributedLineGroup *group2 = [engine2 parseANSIString:@"Text2"];

    SSAttributedLineGroupItem *item1 = group1.lines.firstObject;
    SSAttributedLineGroupItem *item2 = group2.lines.firstObject;

    NSDictionary *attrs1 = [item1.line attributesAtIndex:0 effectiveRange:NULL];
    NSDictionary *attrs2 = [item2.line attributesAtIndex:0 effectiveRange:NULL];

    UIColor *color1 = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs1[(id)kCTForegroundColorAttributeName]];
    UIColor *color2 = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs2[(id)kCTForegroundColorAttributeName]];

    UIColor *expectedRed = [UIColor colorForSGRCode:SPLSGRCodeFgRed defaultColor:kDefaultColor];
    UIColor *expectedGreen = [UIColor colorForSGRCode:SPLSGRCodeFgGreen defaultColor:kDefaultColor];

    EXP_expect(color1).to.equal(expectedRed);
    EXP_expect(color2).to.equal(expectedGreen);
}

#pragma mark - Default Color Changes

- (void)testState_ChangingDefaultColorAffectsSubsequentParsing {
    // Parse with one default color
    engine.defaultTextColor = [UIColor redColor];
    SSAttributedLineGroup *group1 = [engine parseANSIString:@"Red Default"];

    // Change default and parse again
    engine.defaultTextColor = [UIColor blueColor];
    SSAttributedLineGroup *group2 = [engine parseANSIString:@"\033[0mBlue Default"];

    SSAttributedLineGroupItem *item2 = group2.lines.firstObject;
    NSDictionary *attrs2 = [item2.line attributesAtIndex:0 effectiveRange:NULL];
    UIColor *color2 = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs2[(id)kCTForegroundColorAttributeName]];

    // After reset, should use new default
    EXP_expect(color2).to.equal([UIColor blueColor]);
}

#pragma mark - Edge Cases

- (void)testState_EmptyStringDoesNotAffectState {
    // Set a color
    [engine parseANSIString:@"\033[31mRed"];

    // Parse empty string
    [engine parseANSIString:@""];

    // State should still be red
    SSAttributedLineGroup *group = [engine parseANSIString:@"Still Red"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];

    UIColor *expectedColor = [UIColor colorForSGRCode:SPLSGRCodeFgRed defaultColor:kDefaultColor];
    EXP_expect(color).to.equal(expectedColor);
}

- (void)testState_OnlyEscapeCodesAffectState {
    // Parse string with only escape codes
    [engine parseANSIString:@"\033[31m\033[44m"];

    // State should be red on blue, even without text
    SSAttributedLineGroup *group = [engine parseANSIString:@"Text"];
    SSAttributedLineGroupItem *item = group.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];

    UIColor *fgColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];
    UIColor *bgColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[kTTTBackgroundFillColorAttributeName]];

    UIColor *expectedFg = [UIColor colorForSGRCode:SPLSGRCodeFgRed defaultColor:kDefaultColor];
    UIColor *expectedBg = [UIColor colorForSGRCode:SPLSGRCodeBgBlue defaultColor:nil];

    EXP_expect(fgColor).to.equal(expectedFg);
    EXP_expect(bgColor).to.equal(expectedBg);
}

@end
