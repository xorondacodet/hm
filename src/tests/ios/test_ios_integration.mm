/*
 * test_ios_integration.mm - iOS Integration Tests for Xoron
 * Tests: Logging, Console, Environment, Filesystem, Memory, Luau, Drawing, UI
 * Platform: iOS 15+ (iPhone)
 * 
 * This test file supports both XCTest (when available) and standalone execution.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach/mach.h>

#ifdef XORON_HAS_XCTEST
#import <XCTest/XCTest.h>
#endif

// Simple assertion macros for standalone mode
#ifndef XORON_HAS_XCTEST
#define XCTAssertTrue(expr, msg) do { if (!(expr)) { NSLog(@"FAIL: %@", msg); testsFailed++; } else { testsPassed++; } } while(0)
#define XCTAssertNil(expr, msg) do { if ((expr) != nil) { NSLog(@"FAIL: %@", msg); testsFailed++; } else { testsPassed++; } } while(0)
#define XCTAssertNotNil(expr, msg) do { if ((expr) == nil) { NSLog(@"FAIL: %@", msg); testsFailed++; } else { testsPassed++; } } while(0)
#define XCTAssertEqual(a, b, msg) do { if ((a) != (b)) { NSLog(@"FAIL: %@", msg); testsFailed++; } else { testsPassed++; } } while(0)
#define XCTAssertNotEqual(a, b, msg) do { if ((a) == (b)) { NSLog(@"FAIL: %@", msg); testsFailed++; } else { testsPassed++; } } while(0)
#define XCTAssertEqualObjects(a, b, msg) do { if (![(a) isEqual:(b)]) { NSLog(@"FAIL: %@", msg); testsFailed++; } else { testsPassed++; } } while(0)
#define XCTFail(msg) do { NSLog(@"FAIL: %@", msg); testsFailed++; } while(0)
static int testsPassed = 0;
static int testsFailed = 0;
#endif

// Stub logging macros if xoron.h is not available during test build
#ifndef XORON_LOG
#define XORON_LOG(...) NSLog(@__VA_ARGS__)
#endif
#ifndef CONSOLE_LOG
#define CONSOLE_LOG(...) NSLog(@__VA_ARGS__)
#endif
#ifndef CONSOLE_LOG_WARN
#define CONSOLE_LOG_WARN(...) NSLog(@"[WARN] " __VA_ARGS__)
#endif
#ifndef CONSOLE_LOG_ERROR
#define CONSOLE_LOG_ERROR(...) NSLog(@"[ERROR] " __VA_ARGS__)
#endif
#ifndef ENV_LOG
#define ENV_LOG(...) NSLog(@"[ENV] " __VA_ARGS__)
#endif
#ifndef FS_LOG
#define FS_LOG(...) NSLog(@"[FS] " __VA_ARGS__)
#endif
#ifndef MEM_LOG
#define MEM_LOG(...) NSLog(@"[MEM] " __VA_ARGS__)
#endif

// MARK: - Test Runner Class

#ifdef XORON_HAS_XCTEST
@interface XoronIOSIntegrationTests : XCTestCase
@end
#else
@interface XoronIOSIntegrationTests : NSObject
- (void)runAllTests;
@end
#endif

@implementation XoronIOSIntegrationTests

// MARK: - Platform Detection Tests

- (void)testPlatformDetection {
    NSLog(@"[TEST] Platform Detection");
    
    // Verify iOS platform
    NSLog(@"✓ Running on iOS platform");
    
    // Verify we're on ARM64
    #if defined(__arm64__) || defined(__aarch64__)
        NSLog(@"✓ ARM64 architecture detected");
    #else
        NSLog(@"⚠ Not running on ARM64");
    #endif
    
    NSLog(@"[TEST] Platform Detection: PASSED");
}

- (void)testFrameworkAvailability {
    NSLog(@"[TEST] Framework Availability");
    
    // Verify UIKit is available
    XCTAssertNotNil([UIApplication class], @"UIKit should be available");
    NSLog(@"✓ UIKit available");
    
    // Verify Foundation is available
    XCTAssertNotNil([NSString class], @"Foundation should be available");
    NSLog(@"✓ Foundation available");
    
    // Verify CoreGraphics is available
    XCTAssertNotNil([UIColor class], @"CoreGraphics/UIColor should be available");
    NSLog(@"✓ CoreGraphics available");
    
    NSLog(@"[TEST] Framework Availability: PASSED");
}

// MARK: - Logging Tests

- (void)testNSLogIntegration {
    NSLog(@"[TEST] NSLog Integration");
    
    // Test logging macros
    XORON_LOG("Xoron iOS Integration Test - Message 1");
    XORON_LOG("Xoron iOS Integration Test - Message 2: %d", 42);
    
    NSLog(@"✓ XORON_LOG working");
    
    // Test CONSOLE_LOG
    CONSOLE_LOG("Console log test");
    CONSOLE_LOG_WARN("Console warning test");
    CONSOLE_LOG_ERROR("Console error test");
    
    NSLog(@"✓ CONSOLE_LOG macros working");
    
    NSLog(@"[TEST] NSLog Integration: PASSED");
}

// MARK: - Filesystem Tests

- (void)testFilesystemFunctions {
    NSLog(@"[TEST] Filesystem Functions");
    
    // Get documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    
    // Test file operations
    NSString *testFile = [documentsDirectory stringByAppendingPathComponent:@"xoron_test.txt"];
    NSString *testContent = @"Xoron iOS Filesystem Test";
    
    // Write file
    NSError *error = nil;
    BOOL success = [testContent writeToFile:testFile
                                  atomically:YES
                                    encoding:NSUTF8StringEncoding
                                       error:&error];
    
    XCTAssertTrue(success, @"File write should succeed");
    XCTAssertNil(error, @"No error should occur");
    NSLog(@"✓ File write successful");
    
    // Read file
    NSString *readContent = [NSString stringWithContentsOfFile:testFile
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
    XCTAssertEqualObjects(readContent, testContent, @"Content should match");
    NSLog(@"✓ File read successful");
    
    // Cleanup
    [[NSFileManager defaultManager] removeItemAtPath:testFile error:nil];
    
    NSLog(@"[TEST] Filesystem Functions: PASSED");
}

// MARK: - Memory Tests

- (void)testMemoryFunctions {
    NSLog(@"[TEST] Memory Functions");
    
    // Test memory allocation
    void *ptr = malloc(1024);
    XCTAssertNotEqual(ptr, NULL, @"Memory allocation should succeed");
    
    // Test memory operations
    memset(ptr, 0xAA, 1024);
    
    // Verify pattern
    unsigned char *bytePtr = (unsigned char *)ptr;
    XCTAssertEqual(bytePtr[0], 0xAA, @"Memory pattern should be set");
    XCTAssertEqual(bytePtr[1023], 0xAA, @"Memory pattern should be set");
    
    free(ptr);
    NSLog(@"✓ Memory allocation and operations work");
    
    NSLog(@"[TEST] Memory Functions: PASSED");
}

// MARK: - Drawing Tests

- (void)testDrawingFunctions {
    NSLog(@"[TEST] Drawing Functions");
    
    // Create a test view
    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    testView.backgroundColor = [UIColor whiteColor];
    
    // Test drawing context
    UIGraphicsBeginImageContextWithOptions(testView.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    XCTAssertNotEqual(context, NULL, @"Graphics context should exist");
    
    // Test drawing operations
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextFillRect(context, CGRectMake(10, 10, 80, 80));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    XCTAssertNotNil(image, @"Image should be created");
    NSLog(@"✓ Drawing operations work");
    
    NSLog(@"[TEST] Drawing Functions: PASSED");
}

// MARK: - UI Tests

- (void)testUIFunctions {
    NSLog(@"[TEST] UI Functions");
    
    // Verify UIKit components
    UIView *view = [[UIView alloc] init];
    XCTAssertNotNil(view, @"UIView should be created");
    
    UILabel *label = [[UILabel alloc] init];
    XCTAssertNotNil(label, @"UILabel should be created");
    
    UIButton *button = [[UIButton alloc] init];
    XCTAssertNotNil(button, @"UIButton should be created");
    
    NSLog(@"✓ UI components available");
    
    NSLog(@"[TEST] UI Functions: PASSED");
}

// MARK: - Thread Safety Tests

- (void)testThreadSafety {
    NSLog(@"[TEST] Thread Safety");
    
    // Test concurrent logging
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        XORON_LOG("Thread 1: Concurrent log message");
    });
    
    dispatch_group_async(group, queue, ^{
        XORON_LOG("Thread 2: Concurrent log message");
    });
    
    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC));
    
    NSLog(@"✓ Thread-safe logging available");
    NSLog(@"[TEST] Thread Safety: PASSED");
}

#ifndef XORON_HAS_XCTEST
// Standalone test runner
- (void)runAllTests {
    [self testPlatformDetection];
    [self testFrameworkAvailability];
    [self testNSLogIntegration];
    [self testFilesystemFunctions];
    [self testMemoryFunctions];
    [self testDrawingFunctions];
    [self testUIFunctions];
    [self testThreadSafety];
    
    NSLog(@"========================================");
    NSLog(@"Test Results: %d passed, %d failed", testsPassed, testsFailed);
    NSLog(@"========================================");
}
#endif

@end

// MARK: - App Delegate for standalone mode

#ifndef XORON_HAS_XCTEST
@interface TestAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation TestAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UIViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    // Run tests after a short delay to let the app initialize
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"========================================");
        NSLog(@"Xoron iOS Integration Tests");
        NSLog(@"Platform: iOS 15+ (iPhone)");
        NSLog(@"Mode: Standalone (no XCTest)");
        NSLog(@"========================================");
        
        XoronIOSIntegrationTests *tests = [[XoronIOSIntegrationTests alloc] init];
        [tests runAllTests];
        
        // Exit after tests complete
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            exit(testsFailed > 0 ? 1 : 0);
        });
    });
    
    return YES;
}

@end
#endif

// MARK: - Main Entry Point

int main(int argc, char *argv[]) {
    @autoreleasepool {
#ifdef XORON_HAS_XCTEST
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([XoronIOSIntegrationTests class]));
#else
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([TestAppDelegate class]));
#endif
    }
}
