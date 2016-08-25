#import "GASection.h"

@implementation GASection

- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"%li  |  %f, %f, %f", (long)self.sectionNumber, self.minValue, self.midValue, self.maxValue];
    return description;
}
@end
