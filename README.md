# appvisor_flutter_sdk

This repository contains the source code for the Appvisor Push Flutter SDK.  
[japanese_translation 日本語](./README_jp.md)

<details>
  <summary>Table of Contents</summary>

- [appvisor\_flutter\_sdk](#appvisor_flutter_sdk)
  - [Installation](#installation)
    - [Download the SDK](#download-the-sdk)
    - [Integrate the SDK](#integrate-the-sdk)
  - [Usage](#usage)
    - [iOS Setup](#ios-setup)
    - [Android Setup](#android-setup)
    - [Create an instance of the SDK](#create-an-instance-of-the-sdk)
    - [Configuration](#configuration)
    - [Initialization](#initialization)
    - [Custom Properties](#custom-properties)
    - [Configuration (Mandatory for Android; Android Only)](#configuration-mandatory-for-android-android-only)
    - [Notices](#notices)
    - [Notification Data](#notification-data)
    - [Checking for Updates (強制アップデート)](#checking-for-updates-強制アップデート)
    - [Requesting a Store Review](#requesting-a-store-review)
    - [Rich Push Notifications](#rich-push-notifications)
    - [Create a Notification Service Extension](#create-a-notification-service-extension)
    - [Create Notification Content Extensions](#create-notification-content-extensions)
  - [Functions and Properties](#functions-and-properties)
  - [Branches](#branches)
  - [Workflow](#workflow)
  - [Issues Encountered During Project Setup](#issues-encountered-during-project-setup)
</details>

## Installation
### Download the SDK
Download the SDK from [this link](#download-the-sdk).

### Integrate the SDK
1. **Unzip the SDK:** After downloading, extract the SDK to a preferred directory.
2. **Add the SDK to your project:** Update your `pubspec.yaml` file as follows:

```yaml
dependencies:
  appvisor_flutter_sdk:
    path: /path/to/appvisor_flutter_sdk
```

## Usage
### iOS Setup
Follow the steps from iOS setup guide from [Appvsior Website]() until 前提条件.

  > :information_source: Note on Foreground Notifications and Notification Data
  > Please be aware that foreground notifications and notification data may not function correctly upon the first launch of the app. The cause of this issue is currently under investigation.

### Android Setup

Follow these steps to set up the Android environment:

1. **Set the Minimum SDK Version:** Ensure that the minimum SDK version for your Android project is set to 23.

2. **Add Google Services Plugin:** Incorporate the Google services plugin into your Android project. Detailed instructions can be found in the [Firebase Android setup guide](https://firebase.google.com/docs/android/setup?_gl=1*ajvr4q*_up*MQ..*_ga*MjA1NDY2NDE2My4xNzE1NTg1ODc3*_ga_CW55HF8NVT*MTcxNTU4NTg3Ny4xLjAuMTcxNTU4NTg3Ny4wLjAuMA..#add-config-file). Note: It's not necessary to add any Firebase SDKs unless they are specifically required for your project.

  > :warning: **Important Note:**
  > During development, version 4.4.x of the Firebase Android SDK was found to have some known issues (see [this GitHub issue](https://github.com/firebase/firebase-android-sdk/issues/4693) for details). As a result, version 4.3.15 was used in the example app. If you encounter any issues with version 4.4.x, consider switching to version 4.3.15.

3. **Update `android/settings.gradle` File:** Add the following to your `android/settings.gradle` file:

```gradle

include ":app"

def flutterProjectRoot = rootProject.projectDir.parentFile.toPath()

def plugins = new Properties()
def pluginsFile = new File(flutterProjectRoot.toFile(), '.flutter-plugins')
if (pluginsFile.exists()) {
    pluginsFile.withInputStream { stream -> plugins.load(stream) }
}

plugins.each { name, path ->
    def pluginDirectory = flutterProjectRoot.resolve(path).resolve('android').toFile()
    def settings = flutterProjectRoot.resolve(path).resolve('android/settings.gradle').toFile()
    include ":$name"
    project(":$name").projectDir = pluginDirectory

    if (settings.exists()) {
        apply from: settings
    }
}
``` 

### Create an instance of the SDK

To use the SDK in your application, you first need to create an instance of it. Here's how you can do that:

```dart
// First, import the package into your file.
import 'package:appvisor_flutter_sdk/appvisor_flutter_sdk.dart';

// Create an instance of the SDK
final sdk = AppvisorFlutterSdk();
```

### Configuration (Android Only)
This is not required for iOS.

You need to add your icon files to the `android/app/src/main/res/drawable` directory.
Once you've added your icon files, configure using the `configure` method of the SDK. Here's an example:

```dart
sdk.configure(
  // The name of the notification channel for Android. This is mandatory.
  channelName: 'Appvisor',
  
  // The description of the notification channel for Android. This is mandatory.
  channelDescription: 'Appvisor Push notifications',
  
  // The name of the small icon file that you added to the `android/app/src/main/res/drawable` directory. This is mandatory.
  // example: android/app/src/main/res/drawable/ic_notification.xml
  smallIcon: 'ic_notification', 
  
  // The name of the large icon file that you added to the `android/app/src/main/res/drawable` directory. This is optional and needs to be a bitmap image.
  // example: android/app/src/main/res/drawable/ic_notification_large.png
  largeIcon: 'ic_notification_large', 
);
``` 

### Initialization

To utilize the Appvisor Flutter SDK in your application, you must first initialize it. This can be accomplished by calling the `init` function. 
Please note that this function counts the number of times the app has been opened. It should be placed in a location that ensures its execution upon each app launch.

```dart
// Initialize the SDK with your app key
// Replace 'YOUR_*_APP_KEY' with your actual app key
String appKey;
if (Platform.isAndroid) {
  appKey = "YOUR_ANDROID_APP_KEY";
} else {
  appKey = "YOUR_IOS_APP_KEY";
}
final result = await sdk.init(appKey);
print("SDK initialization ${result.isSuccess ? 'succeeded' : 'failed'}");
result.onFailure((error) {
  print("SDK initialization failed: ${error.message}");
})

```

### Turn on/off Push Notifications
You can toggle push notifications on or off using the `togglePush` method of the SDK. This method takes one parameter:
- `value`: A boolean value indicating whether to enable or disable push notifications.

```dart
final result = await plugin.togglePush(value);
if (result.isSuccess) {
  print("Push notifications toggled successfully");
} else {
  print("Failed to toggle push notifications: ${result.error?.message}");
}
```

### Custom Properties

You can set a custom property using the `setCustomProperty` method of the SDK. This method takes two parameters:

- `parameterId`: This is the ID of the parameter you want to set.
- `value`: This is the value you want to set for the parameter.

Here's an example of how to use it:

```dart
final bool isSuccess = await sdk.setCustomProperty(
  parameterId: 123,
  value: "hello",
);
```

In this example, we're setting the custom property with ID `123` to the value `"hello"`. The method returns a boolean indicating whether the operation was successful or not.

After setting custom properties, you can synchronize these changes with the server using the `syncCustomProperties` method of the SDK. This method ensures that the local changes you've made to the custom properties are updated on the server.

Here's an example of how to use it:

```dart
await sdk.syncCustomProperties();
```

In this example, we're calling the `syncCustomProperties` method to synchronize the local changes with the server. This method should be called after setting custom properties.

You can retrieve a custom property from local storage using the `getCustomProperty` method of the SDK. This method takes one parameter:

- `parameterId`: This is the ID of the parameter you want to retrieve.

Here's an example of how to use it:

```dart
final value = await sdk.getCustomProperty(123);
```

In this example, we're retrieving the value of the custom property with ID `123` from local storage. The method returns the value of the custom property. Please note that this method does not retrieve the property from the server, but only from local storage.

### Get Config 

To fetch Congfig from the server, use the `getConfig()` function from the SDK. This function returns a `Result` object, which you can use to handle success and failure scenarios.

Here's an example:

```dart
final result = await sdk.getConfig();

// Handle success
result.onSuccess((config) {
  // The config is a Map<String, dynamic>
  print("Configuration data: ${config}");
});

// Handle failure
result.onFailure((error) {
  print("Failed to fetch Config: ${error.message}");
});
```

In the success handler, `config` is a `Map<String, dynamic>` that contains the Config. In the failure handler, `error` is an object that contains information about the error that occurred.

### Notices

The SDK provides a method called `getNotices` to fetch notices. This method can be used without any parameters to fetch all notices, or with a `LastKey` object to fetch notices after a specific point.

```dart
// Fetch all notices
final result = await sdk.getNotices();

result.onSuccess((noticeList) {
  // This block is executed when the notice list is successfully fetched
  print("Successfully fetched the notices");

  // Example of how to use the fetched notice list
  var notices = noticeList?.notices;
  for (var notice in notices!) {
    print('Message ID: ${notice.messageId}');
    print('Push Title: ${notice.pushTitle}');
    print('Push Body: ${notice.pushBody}');
    print('Read Status: ${notice.readStatus}');
    print('Timestamp: ${notice.timestamp}');
    print('URL: ${notice.url}');
    print('User UUID: ${notice.userUUID}');
  }
});

result.onFailure((error) {
  // This block is executed when fetching the notice list fails
  print("Failed to fetch notices: ${error.message}");
});
```

If you want to fetch notices after a specific point, you can create a `LastKey` object with the desired messageId and userUUID, and pass it as the parameter to the `getNotices` method:

```dart
// Create a LastKey object
const lastKey = LastKey(messageId: 'messageId', userUUID: 'userUUID');

// Fetch notices after the specified LastKey
final result = await sdk.getNotices(lastKey);

// Handle the result as shown in the previous example
```

The SDK also provides a method called `markNoticeAsRead` to mark a notice as read. This method requires the `messageId` of the notice as a parameter.

Here's an example of how to use this method:

```dart
// The messageId of the notice you want to mark as read
final int messageId = 1;

// Call the method with the messageId
final result = await sdk.markNoticeAsRead(messageId);

// The method returns a Result object, which can be either a success or a failure
result.onSuccess((_) {
  // This block is executed when the notice is successfully marked as read
  print("Notice marked as read.");
});

result.onFailure((error) {
  // This block is executed when marking the notice as read fails
  print("Failed to mark notice as read: ${error.message}");
});
```

Please replace `1` with the actual `messageId` of the notice you want to mark as read.

### Notification Data

The SDK offers a stream named `notificationData` that emits the data from a notification whenever one is received.

Below is a sample usage of this stream:

```dart
// Call the getNotificationData method
sdk.notificationData.listen((data) {
  // Check if the data is not null before using it
  if (data != null) {
    // Print the data fields
    print("Title: ${data.title}");
    print("Message: ${data.message}");
    print("W: ${data.w}");
    print("X: ${data.x}");
    print("Y: ${data.y}");
    print("Z: ${data.z}");
  }
});
```

In this example, `data` is an object that contains the data from the notification. The fields `title` and `message` contain the title and message of the notification, respectively. The fields `w`, `x`, `y`, and `z` contain additional data.

### Checking for Updates (強制アップデート)

You can check for updates using the `checkForUpdates` method of the SDK. This method takes three optional parameters:

- `useSDKDialog`: Set this to `true` to show the SDK dialog, or `false` to not show it.
- `onDismiss`: This is a callback that is called when the user dismisses the dialog.
- `onNavigationToStore`: This is a callback that is called when the user navigates to the store.

Here's an example of how to use it:

```dart
final result = await sdk.checkForUpdates(
    useSDKDialog: true,
    onDismiss: () {
      print("User dismissed the dialog");
    },
    onNavigationToStore: () {
      print("User navigated to the store");
    },
);
result.onSuccess((update) {
  print("Store URL: ${update.storeUrl}");
  print("Update is optional: ${update.optional}");
});
result.onFailure((error) {
  print("Failed to check for updates: ${error.message}");
});
```

In this example, we're checking for updates and handling the result. If the check is successful, we print the store URL and whether the update is optional. If the check fails, we print an error message.

### Requesting a Store Review

You can prompt the user to review your app using the `requestAppReview` method of the SDK. This method triggers the native app review dialog on both iOS and Android.

Here's an example of how to use it:

```dart
sdk.requestAppReview();
```

In this example, we're calling the `requestAppReview` method to prompt the user to review the app. Please note that the actual display of the review dialog is up to the operating system and may not always appear when this method is called.

### Rich Push Notifications

This setup is only required for iOS. Android does not require any additional setup for rich push notifications. 

#### Create a Notification Service Extension

To create a Notification Service Extension, follow these steps:

1. Open your project in Xcode.
2. Navigate to `File > New > Target…` and select `Notification Service Extension`.
3. Set the product name. For this example, we'll use "NotificationServiceExtension".
4. For both 'Project' and `Embed in Application`, select `Runner`.
5. Click 'Finish'.

See the image below:

![Notification Service Extension Creation](./assets/nse_creation.png)

After completing these steps, set the 'Minimum Deployment Target' to 14.0. Then, add `AppVisorSDK.xcframework` to the NotificationServiceExtension target's 'Frameworks, Libraries, and Embedded Content' section.

![Notification Service Extension Target Configuration](./assets/nse_target_configuration.png)

Next, navigate to `NotificationService.swift` and replace the existing code with the following:

```swift
import UserNotifications
import AppVisorSDK

class NotificationService: UNNotificationServiceExtension {

  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?

  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
    
    if let bestAttemptContent = bestAttemptContent {
      Appvisor.sharedInstance.handleContent(bestAttemptContent, withHandler: contentHandler)
    }
  }
  
  override func serviceExtensionTimeWillExpire() {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }
}

```

#### Create Notification Content Extensions

Follow these steps to create a Notification Content Extension:

1. Open your project in Xcode.
2. Click on `File > New > Target…` in the menu at the top of the screen. Select `Notification Content Extension`.
3. In the `Product Name` field, type "NotificationContentExtensionImage".
4. In the `Project` and `Embed in Application` fields, select `Runner`.
5. Click 'Finish'.

  ![Notification Content Extension Creation](./assets/nce_creation.png)

6. In the `Deployment Info` section, set the `Minimum Deployment Target` to 14.0.
7. In the `Frameworks, Libraries, and Embedded Content` section, click the '+' button and add `AppVisorSDK.xcframework`.

  ![Notification Content Extension Target Configuration](./assets/nce_target_configuration.png)

8. Navigate to `MainInterface.storyboard` and delete the existing View from the view controller.

  ![Notification Content Extension Main Interface](./assets/main_interface.png)

9. Click on `Info.plist` and navigate to `Information Property List>NSExtension>NSExtensionAttributes>UNNotificationExtensionCategory`. Set the value to `AppvisorRichPushImageCategory`.
10. Click on `NotificationViewController.swift`, delete the existing code and replace it with the following:

```swift
import UIKit
import UserNotifications
import UserNotificationsUI
import AppVisorSDK

class NotificationViewController: UIViewController, UNNotificationContentExtension {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any required interface initialization here.
  }
  
  func didReceive(_ notification: UNNotification) {
    Appvisor.sharedInstance.showImage(from: notification, in: self.view)
  }
}
```

Repeat these steps two more times to create `NotificationContentExtensionVideo` and `NotificationContentExtensionWeb`. 

For `NotificationContentExtensionVideo`, in step 3, use "NotificationContentExtensionVideo" as the product name. In step 9, set the value to `AppvisorRichPushMovieCategory`. In step 10, replace the code with:

```swift
import UIKit
import UserNotifications
import UserNotificationsUI
import AppVisorSDK

class NotificationViewController: UIViewController, UNNotificationContentExtension {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any required interface initialization here.
  }
  
  func didReceive(_ notification: UNNotification) {
    Appvisor.sharedInstance.showMovieRichPush(notification, in: self.view)
  }
}
```

For `NotificationContentExtensionWeb`, in step 3, use "NotificationContentExtensionWeb" as the product name. In step 9, set the value to `AppvisorRichPushCategory`. In step 10, replace the code with:

```swift
import UIKit
import UserNotifications
import UserNotificationsUI
import AppVisorSDK

class NotificationViewController: UIViewController, UNNotificationContentExtension {    
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any required interface initialization here.
  }
  
  func didReceive(_ notification: UNNotification) {
    Appvisor.sharedInstance.showWebSite(from: notification, in: self.view)
    self.preferredContentSize = CGSize(width: 320, height: 299)
  }
}
```
> :exclamation: **Important:**
> If you encounter the error **"Cycle inside Runner; building could produce unreliable results…"**, adjust the order of the Runner's build phases as shown below:
>
> ![Build Phases](./assets/build_phases.png)


## Functions and Properties

| Function/Property | Description | Parameters | Return Type |
| --- | --- | --- | --- |
| `deviceId` | A unique identifier for the device. | None | Future<String?> |
| `isPushEnabled` | Checks if push is enabled. | None | Future\<bool\> |
| `init(appKey, [enableLogs])` | Initializes the SDK. | `appKey`: String, `enableLogs`: bool? | Future<Result<Null>> |
| `configure(channelName, channelDescription, smallIconName, [largeIconName, defaultTitle])` | Configures the SDK with options. | `channelName`: String, `channelDescription`: String, `smallIconName`: String, `largeIconName`: String?, `defaultTitle`: String? | Future<Result<Null>> |
| `togglePush(enable)` | Enables or disables push notifications. | `enable`: bool | Future<Result<bool>> |
| `getCustomProperty(parameterId)` | Retrieves a custom property. | `parameterId`: int | Future\<String?\> |
| `setCustomProperty({required parameterId, value})` | Sets a custom property. | `parameterId`: int, `value`: String? | Future\<bool\> |
| `syncCustomProperties()` | Synchronizes the custom properties with the server. | None | Future<Result<Null>> |
| `checkForUpdate({useSDKDialog, onDismiss, onNavigationToStore})` | Checks for updates. | `useSDKDialog`: bool?, `onDismiss`: Function?, `onNavigationToStore`: Function? | Future<Result<UpdateData?>> |
| `requestAppReview()` | Requests an app review. | None | Future\<void\> |
| `getConfig()` | Retrieves the configuration. | None | Future<Result<Map<String, dynamic>>> |
| `getNotices([lastKey])` | Retrieves the notices. | `lastKey`: LastKey? | Future<Result<NoticeList?>> |
| `markNoticeAsRead(messageId)` | Marks a notice as read. | `messageId`: int | Future<Result<Null>> |
| `notificationData` | A stream that emits the data from a notification whenever one is received. | None | Stream\<NotificationData\>

## Branches

- `production`: The production branch.
- `staging`: The staging branch.
- `develop`: The development branch.

## Workflow

1. Develop new features and fixes in the `develop` branch.
2. When ready for testing, merge the changes into the `staging` branch and add a tag.
3. If there are any fixes required in the `develop` branch, merge them into the `staging` branch.
4. When ready to release, merge the `staging` branch into the `production` branch and add a tag.

## Issues Encountered During Project Setup

During project setup, an issue occured when adding a local `.aar` library. The issue stemmed from the fact that direct local `.aar` file dependencies are not supported when building an AAR.
A solution to this problem was found on [StackOverflow](https://stackoverflow.com/questions/60878599/error-building-android-library-direct-local-aar-file-dependencies-are-not-supp). However, implementing this solution led to another issue when running the example app, as documented in this [Flutter GitHub issue](https://github.com/flutter/flutter/issues/17150).

This secondary issue was resolved using the fix suggested in [this comment](https://github.com/flutter/flutter/issues/17150#issuecomment-1249450980) on the same GitHub issue thread.
