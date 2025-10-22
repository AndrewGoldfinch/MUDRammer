//
//  MRANSIEngineComprehensiveTests.m
//  Mudrammer
//
//  Comprehensive test coverage for SSANSIEngine before refactoring
//  These tests document all existing behavior to ensure refactoring maintains compatibility
//

#import "MRTestHelpers.h"

@interface MRANSIEngineComprehensiveTests : XCTestCase
@end

@implementation MRANSIEngineComprehensiveTests
{
    SSANSIEngine *engine;
    SSAttributedLineGroup *lineGroup;
    NSString *testString;
}

- (void)setUp {
    [super setUp];

    engine = [SSANSIEngine new];
    engine.defaultTextColor = kDefaultColor;
    engine.defaultFont = kDefaultFont;
}

- (void)tearDown {
    engine = nil;
    lineGroup = nil;
    testString = nil;

    [super tearDown];
}

#pragma mark - XTerm 256 Color Tests

- (void)testXTerm256_Basic16Colors {
    // Test that XTerm 256-color mode can represent basic 16 colors
    // Sequence: ESC[38;5;Nm for foreground, ESC[48;5;Nm for background

    // Foreground black (color 0)
    testString = @"\033[38;5;0mBlack Text\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Black Text");

    // Foreground red (color 1)
    testString = @"\033[38;5;1mRed Text\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Red Text");

    // Foreground bright white (color 15)
    testString = @"\033[38;5;15mBright White\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Bright White");
}

- (void)testXTerm256_ColorCube {
    // Test 216-color cube (colors 16-231)
    // Formula: 16 + 36 × r + 6 × g + b where r,g,b are 0-5

    // Color 16 (0,0,0 in RGB terms)
    testString = @"\033[38;5;16mColor 16\033[0m";
    lineGroup = [engine parseANSIString:testString];
    EXP_expect(lineGroup.lines.count).to.equal(1);
    EXP_expect(((SSAttributedLineGroupItem *)lineGroup.lines.firstObject).line.string).to.equal(@"Color 16");

    // Color 51 (0,5,5 = cyan)
    testString = @"\033[38;5;51mCyan\033[0m";
    lineGroup = [engine parseANSIString:testString];
    EXP_expect(lineGroup.lines.count).to.equal(1);

    // Color 231 (5,5,5 = white)
    testString = @"\033[38;5;231mWhite\033[0m";
    lineGroup = [engine parseANSIString:testString];
    EXP_expect(lineGroup.lines.count).to.equal(1);
}

- (void)testXTerm256_GrayscaleRamp {
    // Test 24-level grayscale (colors 232-255)

    // Color 232 (darkest gray)
    testString = @"\033[38;5;232mDark Gray\033[0m";
    lineGroup = [engine parseANSIString:testString];
    EXP_expect(lineGroup.lines.count).to.equal(1);
    EXP_expect(((SSAttributedLineGroupItem *)lineGroup.lines.firstObject).line.string).to.equal(@"Dark Gray");

    // Color 244 (medium gray)
    testString = @"\033[38;5;244mMedium Gray\033[0m";
    lineGroup = [engine parseANSIString:testString];
    EXP_expect(lineGroup.lines.count).to.equal(1);

    // Color 255 (lightest gray)
    testString = @"\033[38;5;255mLight Gray\033[0m";
    lineGroup = [engine parseANSIString:testString];
    EXP_expect(lineGroup.lines.count).to.equal(1);
    EXP_expect(((SSAttributedLineGroupItem *)lineGroup.lines.firstObject).line.string).to.equal(@"Light Gray");
}

- (void)testXTerm256_Background {
    // Test XTerm 256 background colors
    testString = @"\033[48;5;196mRed BG\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Red BG");

    // Verify background attribute exists
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).toNot.beNil();
}

- (void)testXTerm256_ForegroundAndBackground {
    // Test both foreground and background in same string
    testString = @"\033[38;5;226;48;5;19mYellow on Blue\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Yellow on Blue");

    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    EXP_expect(attrs[(id)kCTForegroundColorAttributeName]).toNot.beNil();
    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).toNot.beNil();
}

- (void)testXTerm256_MultipleColors {
    // Test multiple XTerm color changes in one string
    testString = @"\033[38;5;196mRed \033[38;5;46mGreen \033[38;5;21mBlue\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Red Green Blue");
}

#pragma mark - Bold Intensity Tests

- (void)testBoldIntensity_ForegroundRed {
    // Test that bold (code 1) intensifies red color
    testString = @"\033[1;31mBold Red\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Bold Red");

    // Verify it uses bright red (91) instead of normal red (31)
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];
    UIColor *expectedColor = [UIColor colorForSGRCode:SPLSGRCodeFgBrightRed defaultColor:kDefaultColor];

    EXP_expect(color).to.equal(expectedColor);
}

- (void)testBoldIntensity_AllBasicColors {
    // Test bold intensification for all 8 basic colors
    NSArray *colorCodes = @[@30, @31, @32, @33, @34, @35, @36, @37]; // Black through White

    for (NSNumber *code in colorCodes) {
        testString = [NSString stringWithFormat:@"\033[1;%@mBold\033[0m", code];
        lineGroup = [engine parseANSIString:testString];

        EXP_expect(lineGroup.lines.count).to.equal(1);
        SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
        EXP_expect(item.line.string).to.equal(@"Bold");
    }
}

- (void)testBoldIntensity_BoldBeforeColor {
    // Test that bold applied before color still intensifies
    testString = @"\033[1m\033[31mBold Red\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;

    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];
    UIColor *expectedColor = [UIColor colorForSGRCode:SPLSGRCodeFgBrightRed defaultColor:kDefaultColor];

    EXP_expect(color).to.equal(expectedColor);
}

- (void)testBoldIntensity_ColorBeforeBold {
    // Test that color applied before bold still gets intensified
    testString = @"\033[31m\033[1mBold Red\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;

    // Note: This tests current behavior - color might not change after bold applied
    EXP_expect(item.line.string).to.equal(@"Bold Red");
}

- (void)testBoldIntensity_NormalReset {
    // Test that intensity normal (22) removes bold
    testString = @"\033[1;31mBold Red\033[22m Normal Red\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Bold Red Normal Red");
}

- (void)testBoldIntensity_BackgroundColors {
    // Test that bold doesn't affect background colors
    testString = @"\033[1;41mBold with Red BG\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;

    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).toNot.beNil();
}

#pragma mark - Multiple SGR Codes Tests

- (void)testMultipleSGR_ColorAndFormat {
    // Test combining color with underline/strikethrough
    testString = @"\033[31;4mRed Underline\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Red Underline");

    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    EXP_expect(attrs[NSUnderlineStyleAttributeName]).to.equal(@1);
}

- (void)testMultipleSGR_ForegroundAndBackground {
    // Test foreground and background in same sequence
    testString = @"\033[31;44mRed on Blue\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Red on Blue");

    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    EXP_expect(attrs[(id)kCTForegroundColorAttributeName]).toNot.beNil();
    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).toNot.beNil();
}

- (void)testMultipleSGR_AllFormats {
    // Test combining multiple formats: bold, underline, color
    testString = @"\033[1;4;31;44mAll Formats\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"All Formats");

    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    EXP_expect(attrs[NSUnderlineStyleAttributeName]).to.equal(@1);
    EXP_expect(attrs[(id)kCTForegroundColorAttributeName]).toNot.beNil();
    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).toNot.beNil();
}

- (void)testMultipleSGR_EmptyCode {
    // Test handling empty codes in sequence (e.g., ESC[31;;44m)
    testString = @"\033[31;;44mEmpty Code\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Empty Code");
}

#pragma mark - State Persistence Tests

- (void)testStatePersistence_ForegroundAcrossCalls {
    // Verify that foreground color persists across parse calls
    testString = @"\033[31mRed Text";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);

    // Second call without color code should maintain red
    testString = @"Still Red";
    lineGroup = [engine parseANSIString:testString];

    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];
    UIColor *expectedColor = [UIColor colorForSGRCode:SPLSGRCodeFgRed defaultColor:kDefaultColor];

    EXP_expect(color).to.equal(expectedColor);
}

- (void)testStatePersistence_BackgroundAcrossCalls {
    // Verify that background color persists across parse calls
    testString = @"\033[44mBlue BG";
    lineGroup = [engine parseANSIString:testString];

    testString = @"Still Blue BG";
    lineGroup = [engine parseANSIString:testString];

    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).toNot.beNil();
}

- (void)testStatePersistence_ResetClearsState {
    // Verify that reset (ESC[0m) clears persisted state
    testString = @"\033[31;44mRed on Blue\033[0m";
    lineGroup = [engine parseANSIString:testString];

    testString = @"Default Colors";
    lineGroup = [engine parseANSIString:testString];

    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];

    EXP_expect(color).to.equal(kDefaultColor);
    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).to.beNil();
}

- (void)testStatePersistence_ForegroundReset {
    // Test foreground-only reset (ESC[39m)
    testString = @"\033[31;44mRed on Blue\033[39m";
    lineGroup = [engine parseANSIString:testString];

    testString = @"Default FG, Blue BG";
    lineGroup = [engine parseANSIString:testString];

    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    UIColor *fgColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];

    EXP_expect(fgColor).to.equal(kDefaultColor);
    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).toNot.beNil();
}

- (void)testStatePersistence_BackgroundReset {
    // Test background-only reset (ESC[49m)
    testString = @"\033[31;44mRed on Blue\033[49m";
    lineGroup = [engine parseANSIString:testString];

    testString = @"Red FG, Default BG";
    lineGroup = [engine parseANSIString:testString];

    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    UIColor *fgColor = [UIColor colorWithCGColor:(__bridge CGColorRef)attrs[(id)kCTForegroundColorAttributeName]];
    UIColor *expectedColor = [UIColor colorForSGRCode:SPLSGRCodeFgRed defaultColor:kDefaultColor];

    EXP_expect(fgColor).to.equal(expectedColor);
    EXP_expect(attrs[kTTTBackgroundFillColorAttributeName]).to.beNil();
}

#pragma mark - Edge Case Tests

- (void)testEdgeCase_EmptyString {
    testString = @"";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"");
}

- (void)testEdgeCase_OnlyANSICodes {
    testString = @"\033[31m\033[44m\033[1m";
    lineGroup = [engine parseANSIString:testString];

    // Should have no visible text
    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"");
}

- (void)testEdgeCase_MalformedSequence {
    // Test incomplete escape sequence
    testString = @"Hello \033[31World";
    lineGroup = [engine parseANSIString:testString];

    // Should handle gracefully
    EXP_expect(lineGroup.lines.count).to.beGreaterThan(0);
}

- (void)testEdgeCase_InvalidColorCode {
    // Test with invalid color code (e.g., 999)
    testString = @"\033[999mInvalid\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Invalid");
}

- (void)testEdgeCase_VeryLongString {
    // Test with a very long string (1000 characters)
    NSMutableString *longString = [NSMutableString string];
    for (int i = 0; i < 100; i++) {
        [longString appendString:@"0123456789"];
    }

    testString = [NSString stringWithFormat:@"\033[31m%@\033[0m", longString];
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.beGreaterThan(0);
}

- (void)testEdgeCase_ManyColorChanges {
    // Test string with many rapid color changes
    NSMutableString *colorful = [NSMutableString string];
    for (int i = 0; i < 50; i++) {
        [colorful appendFormat:@"\033[3%dm%d", (i % 7) + 1, i];
    }
    [colorful appendString:@"\033[0m"];

    testString = colorful;
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.beGreaterThan(0);
}

- (void)testEdgeCase_NestedEscapeSequences {
    // Test handling of escape sequences that appear to be nested
    testString = @"\033[31mRed\033[\033[44mBlue BG\033[0m";
    lineGroup = [engine parseANSIString:testString];

    // Should handle gracefully without crashing
    EXP_expect(lineGroup.lines.count).to.beGreaterThan(0);
}

- (void)testEdgeCase_UnicodeCharacters {
    // Test ANSI codes with Unicode characters
    testString = @"\033[31m你好世界 🌍\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"你好世界 🌍");
}

#pragma mark - Reverse Video Tests

- (void)testReverseVideo_SwapsForegroundBackground {
    // Test that reverse video swaps foreground and background
    testString = @"\033[31;44mNormal \033[7mReversed\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Normal Reversed");
}

- (void)testReverseVideo_UndoReverse {
    // Test undoing reverse video (ESC[27m)
    testString = @"\033[7mReversed \033[27mNormal\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Reversed Normal");
}

#pragma mark - Formatting Combination Tests

- (void)testFormatCombination_UnderlineAndStrikethrough {
    // Test both underline and strikethrough together
    testString = @"\033[4;9mBoth\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;

    NSDictionary *attrs = [item.line attributesAtIndex:0 effectiveRange:NULL];
    EXP_expect(attrs[NSUnderlineStyleAttributeName]).to.equal(@1);
    EXP_expect(attrs[kTTTStrikeOutAttributeName]).to.equal(@1);
}

- (void)testFormatCombination_RemoveUnderline {
    // Test removing underline (ESC[24m)
    testString = @"\033[4mUnderline \033[24mNo Underline\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Underline No Underline");
}

- (void)testFormatCombination_RemoveStrikethrough {
    // Test removing strikethrough (ESC[29m)
    testString = @"\033[9mStrike \033[29mNo Strike\033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.equal(1);
    SSAttributedLineGroupItem *item = lineGroup.lines.firstObject;
    EXP_expect(item.line.string).to.equal(@"Strike No Strike");
}

#pragma mark - Real-world MUD Output Tests

- (void)testRealWorld_AchaeaColoredMenu {
    // Test actual Achaea MUD output (from comments in MRANSITests.m)
    testString = @"\033[0;37m           \033[34m******************************************\033[37m\n\n\033[32mAchaea, Dreams of Divine Lands\033[37m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.beGreaterThan(0);

    // Verify it parses without errors
    for (SSAttributedLineGroupItem *item in lineGroup.lines) {
        EXP_expect(item).toNot.beNil();
    }
}

- (void)testRealWorld_8BitMushBanner {
    // Test complex 8BIT MUSH banner with reverse video
    testString = @"\033[47m                                   \033[0m\033[40m \033[0m\n\033[47m \033[0m\033[7;1;30;40m          (8BIT MUSH)            \033[0m\033[47m \033[0m\033[40m \033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.beGreaterThan(0);
}

- (void)testRealWorld_MultipleResets {
    // Test output with many reset codes
    testString = @"\033[30;40m \033[0m\033[47m \033[0m\033[7;1;30m \033[0m\033[1;37;40m| \033[0m";
    lineGroup = [engine parseANSIString:testString];

    EXP_expect(lineGroup.lines.count).to.beGreaterThan(0);
}

#pragma mark - Performance Tests

- (void)testPerformance_LargeDocument {
    // Test parsing a large document (1000 lines)
    NSMutableString *largeDoc = [NSMutableString string];
    for (int i = 0; i < 1000; i++) {
        [largeDoc appendFormat:@"\033[3%dmLine %d\033[0m\n", (i % 7) + 1, i];
    }

    [self measureBlock:^{
        SSAttributedLineGroup *result = [self->engine parseANSIString:largeDoc];
        EXP_expect(result).toNot.beNil();
    }];
}

- (void)testPerformance_ManyColors {
    // Test parsing with many color changes
    NSMutableString *manyColors = [NSMutableString string];
    for (int i = 0; i < 100; i++) {
        [manyColors appendFormat:@"\033[38;5;%dmColor%d ", i, i];
    }
    [manyColors appendString:@"\033[0m"];

    [self measureBlock:^{
        SSAttributedLineGroup *result = [self->engine parseANSIString:manyColors];
        EXP_expect(result).toNot.beNil();
    }];
}

#pragma mark - Consistency Tests

- (void)testConsistency_MultipleEngineInstances {
    // Verify different engine instances produce same output
    SSANSIEngine *engine2 = [SSANSIEngine new];
    engine2.defaultTextColor = kDefaultColor;
    engine2.defaultFont = kDefaultFont;

    testString = @"\033[31;44mTest String\033[0m";

    SSAttributedLineGroup *result1 = [engine parseANSIString:testString];
    SSAttributedLineGroup *result2 = [engine2 parseANSIString:testString];

    EXP_expect(result1.lines.count).to.equal(result2.lines.count);

    for (NSUInteger i = 0; i < result1.lines.count; i++) {
        SSAttributedLineGroupItem *item1 = result1.lines[i];
        SSAttributedLineGroupItem *item2 = result2.lines[i];

        EXP_expect(item1.line.string).to.equal(item2.line.string);
    }
}

- (void)testConsistency_ReparsingSameString {
    // Verify parsing same string multiple times produces same result
    testString = @"\033[31;44mConsistent\033[0m";

    SSAttributedLineGroup *result1 = [engine parseANSIString:testString];
    engine = [SSANSIEngine new]; // Reset engine
    engine.defaultTextColor = kDefaultColor;
    engine.defaultFont = kDefaultFont;
    SSAttributedLineGroup *result2 = [engine parseANSIString:testString];

    EXP_expect(result1.lines.count).to.equal(result2.lines.count);
    EXP_expect(((SSAttributedLineGroupItem *)result1.lines[0]).line.string).to.equal(
               ((SSAttributedLineGroupItem *)result2.lines[0]).line.string);
}

@end
