## Requirements

- iOS 6.0 or later.
- ARC

## Features

- monitoring UIPasteboard changes even if your app state is in background.

## Files

- `JRNPasteboardMonitor/`  
JRNPasteboardMonitor files.

- `DemoApp/`  
files for sample application which presents 'copy to pasteboard' action as UILocalNotification.

## Usage

- 1.Add files in `JRNPasteboardMonitor/` to your Xcode project.
- 2.Import JRNPasteboardMonitor.h

```objectivec
#import "JRNPasteboardMonitor.h"
```

- Start monitoring
Just 1 line for starting!
```objectivec
[[JRNPasteboardMonitor defaultMonitor] startMonitoringWithChangeHandler:^(NSString *string) {
    NSLog(@"String you copied is this->%@", string);
}];
```

- End monitoring
If you don't need monitoring, please write it below. just 1 line similary.
```objectivec
[[JRNPasteboardMonitor defaultMonitor] stopMonitoring];
```
## Install
Using [CocoaPods](http://cocoapods.org) is the best way.

```
pod 'JRNPasteboardMonitor'
```

### I don't want to use CocoaPods.
OK, please D&D JRNPasteboardMonitor folder into your project.

## License

Copyright (c) 2013 Naoki Ishikawa

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
