# appvisor_flutter_sdk

このリポジトリには、Appvisor Push Flutter SDKのソースコードが収められています。

<details>
  <summary>Table of Contents</summary>

- [appvisor\_flutter\_sdk](#appvisor_flutter_sdk)
  - [インストール](#インストール)
    - [SDKをダウンロードする](#sdkをダウンロードする)
    - [SDKを組み込む](#sdkを組み込む)
  - [使い方](#使い方)
    - [iOS 設定](#ios-設定)
    - [Android 設定](#android-設定)
    - [SDKのインスタンスを作成する](#sdkのインスタンスを作成する)
    - [Configuration](#configuration)
    - [初期化](#初期化)
    - [カスタム プロパティの登録](#カスタム-プロパティの登録)
    - [設定 (Android の場合は必須、 iOS は不要)](#設定-android-の場合は必須-ios-は不要)
    - [通知](#通知)
    - [Notification Data](#notification-data)
    - [Checking for Updates (強制アップデート)](#checking-for-updates-強制アップデート)
    - [ストアレビューをユーザにうながす](#ストアレビューをユーザにうながす)
    - [Rich Push Notifications](#rich-push-notifications)
    - [通知サービス拡張機能の作成](#通知サービス拡張機能の作成)
      - [通知コンテンツ拡張機能の作成](#通知コンテンツ拡張機能の作成)
  - [Functions and Properties](#functions-and-properties)
  - [ブランチ運用](#ブランチ運用)
  - [ワークフロー](#ワークフロー)
  - [プロジェクトのセットアップ中に発生した問題のメモ](#プロジェクトのセットアップ中に発生した問題のメモ)
</details>

## インストール
### SDKをダウンロードする
[このリンク](#download-the-sdk) から SDK をダウンロードします。

### SDKを組み込む
1. **SDK を解凍します。** ダウンロード後、SDK を任意のディレクトリに抽出します。
2. **SDK をプロジェクトに追加します。** 次のように「pubspec.yaml」ファイルを更新します。

```yaml
dependencies:
  appvisor_flutter_sdk:
    path: /path/to/appvisor_flutter_sdk
```

## 使い方
### iOS 設定
[Appvsior Web サイト](https://www.alpha-stg-client.app-visor.com/client/app/20/Flutter/settings?tab=iOS) の iOS セットアップ ガイドの手順を前提条件まで実行してください。

### Android 設定

Android 環境をセットアップするには、次の手順を実施してください。

1. **最小 SDK バージョンを設定します:**  
   Android プロジェクトの最小 SDK バージョンが 23 に設定されていることを確認してください。  
2. **Googleサービスプラグインを追加:**  
   Google サービス プラグインを Android プロジェクトに組み込みます。詳細な手順については、[Android プロジェクトに Firebase を追加する](https://firebase.google.com/docs/android/setup?_gl=1*ajvr4q*_up*MQ..*_ga*MjA1NDY2NDE2My4xNzE1NTg1ODc3*_ga_CW55HF8NVT*MTcxNTU4NTg3Ny4xLjAuMTcxNTU4NTg3Ny4wLjAuMA..#add-config-file) を参照してください。   
   注: プロジェクトに特に必要でない場合は、Firebase SDK を追加する必要はありません。  
  > :warning: **重要な注意点:**  
  > 開発中に Firebase Android SDK バージョン 4.4.x にいくつかの問題があることが判明しました。 ( 詳細はこちらをご覧ください [this GitHub issue](https://github.com/firebase/firebase-android-sdk/issues/4693) ).  
  その対応として、サンプル アプリではバージョン 4.3.15 を使用しました。バージョン 4.4.x で問題が発生した場合は、バージョン 4.3.15 に切り替えることを検討してください。  
1. **`android/settings.gradle` を更新します:**  
  以下の内容を `android/settings.gradle` に追加してください。  
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

### SDKのインスタンスを作成する

アプリケーションで SDK を使用するには、まず SDK のインスタンスを作成する必要があります。  
手順は以下の通りです:  
  ```dart
  // パッケージをファイルにインポート。
  import 'package:appvisor_flutter_sdk/appvisor_flutter_sdk.dart';

  // SDKのインスタンスを作成する
  final sdk = AppvisorFlutterSdk();
  ```

### Configuration (Android の場合は必須、 iOS は不要)

iOSではこちらの設定は必要ありません。  

アイコンファイルを `android/app/src/main/res/drawable` ディレクトリに追加してください。  

アイコン ファイルを追加したら、SDK の `configure` メソッドを使用して設定します。 
コード例:  
```dart
sdk.configure(
  // Android の通知チャネルの名前。これは必須です.
  channelName: 'Appvisor',
  
  // Android の通知チャネルの説明。これは必須です。
  channelDescription: 'Appvisor Push notifications',
  
  // `android/app/src/main/res/drawable` ディレクトリに追加した小アイコン ファイルの名前。これは必須です。
  // example: android/app/src/main/res/drawable/ic_notification.xml
  smallIcon: 'ic_notification', 
  
  // `android/app/src/main/res/drawable` ディレクトリに追加した大アイコン ファイルの名前。これはオプションです。ビットマップ イメージである必要があります。
  // example: android/app/src/main/res/drawable/ic_notification_large.png
  largeIcon: 'ic_notification_large', 
);
``` 

### 初期化

アプリケーションで Appvisor Flutter SDK を利用するには、`init`関数を使って初期化をします。  
`init`関数は、アプリを開いた回数をカウントします。このため、アプリの起動ごとに確実に実行される場所に配置する必要があります。  

```dart
// アプリキーを使用して SDK を初期化します
// 「YOUR_*_APP_KEY」を実際のアプリキーに置き換えます
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

### カスタム プロパティの登録

SDK の `setCustomProperty` メソッドを使用してカスタム プロパティを設定できます。このメソッドは ID と 値 の二つのパラメータを指定します。

- `parameterId`: カスタムパラメータのIDを指定します.
- `value`: 値を設定します.

Here's an example of how to use it:

```dart
final bool isSuccess = await sdk.setCustomProperty(
  parameterId: 123,
  value: "hello",
);
```

この例では、ID `123` のカスタム プロパティを値 `"hello"` に設定しています。このメソッドは、操作が成功したかどうかを示すブール値を返します。  
カスタム プロパティを設定した後、SDK の `syncCustomProperties` メソッドを使用して、これらの変更をサーバーと同期できます。これにより、カスタム プロパティに加えたローカルの変更をサーバーへ送信します。  

```dart
await sdk.syncCustomProperties();
```

この例では、ローカルの変更をサーバーと同期するために `syncCustomProperties` メソッドを呼び出しています。このメソッドは、カスタム プロパティを設定した後に呼び出す必要があります。  
SDK の「getCustomProperty」メソッドを使用して、ローカル ストレージからカスタム プロパティを取得できます。  
このメソッドはパラメータを 1 つ受け取ります:

- `parameterId`: これは取得するパラメータの ID です。  

使用方法の例は次のとおりです:  
```dart
final value = await sdk.getCustomProperty(123);
```

この例では、ID が「123」のカスタム プロパティの値をローカル ストレージから取得しています。このメソッドはカスタム プロパティの値を返します。このメソッドはサーバーからプロパティを取得するのではなく、ローカル ストレージからのみ取得することに注意してください。

### Get Config 

サーバーから設定情報を取得するには、SDK の `getConfig()` 関数を使用します。  
この関数は `Result` オブジェクトを返します。これを使用して取得成功時と取得失敗時の処理を記述します。  


使用例:  
```dart
final result = await sdk.getConfig();

// 取得成功時の処理
result.onSuccess((config) {
  // The config is a Map<String, dynamic>
  print("Configuration data: ${config}");
});

// エラー時の処理
result.onFailure((error) {
  print("Failed to fetch Config: ${error.message}");
});
```

取得成功時に受け取る `config` は、設定情報を含む `Map<String, Dynamic>` です。   
エラーの場合に受け取る `error` は、発生したエラーに関する情報を含むオブジェクトです。  

### 通知

SDK には、通知を取得するための`get Notices`というメソッドが用意されています。このメソッドをパラメータなしで使用してすべての通知を取得することも、`LastKey`オブジェクトを使用して特定の時点以降の通知を取得することもできます。

```dart
// 全ての通知を取得
final result = await sdk.getNotices();

result.onSuccess((noticeList) {
  // 取得に成功した通知の処理
  print("Successfully fetched the notices");

  // 取得した通知の処理例
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
  // 取得に失敗した場合の処理
  print("Failed to fetch notices: ${error.message}");
});
```

特定の時点以降の通知を取得したい場合は、目的の messageId と userUUID を指定して `LastKey` オブジェクトを作成し、それをパラメーターとして `get Notices` メソッドに渡すことができます。

```dart
// LastKey オブジェクトを作成する
const lastKey = LastKey(messageId: 'messageId', userUUID: 'userUUID');

// 指定された LastKey 以降の通知を取得する
final result = await sdk.getNotices(lastKey);

// 前の例で示したように結果を処理する
```

SDK には、通知を既読としてマークするための `markNoticeAsRead` というメソッドも提供されます。このメソッドにはパラメータとして通知の `messageId` が必要です。

このメソッドの使用例を次に示します:  
```dart
// 既読としてマークしたい通知の messageId
final int messageId = 1;

// messageId を使用してメソッドを呼び出す
final result = await sdk.markNoticeAsRead(messageId);

// 取得した result オブジェクトで成功時、失敗時の処理を記述する
result.onSuccess((_) {
  // 取得成功時の処理
  print("Notice marked as read.");
});

result.onFailure((error) {
  // 失敗時のエラー処理
  print("Failed to mark notice as read: ${error.message}");
});
```

`1`と記述されている部分は実際の`messageId`に置き換えてください。  

### Notification Data

SDK は、通知された内容を受け取るために `notificationData` という名称のデータストリームを提供します。  
以下は、このストリームの使用例です。  
```dart
// getNotificationData メソッドを呼び出す
sdk.notificationData.listen((data) {
  // データを使用する前に、データが null でないかどうかを確認してください
  if (data != null) {
    // データフィールドを印刷する
    print("Title: ${data.title}");
    print("Message: ${data.message}");
    print("W: ${data.w}");
    print("X: ${data.x}");
    print("Y: ${data.y}");
    print("Z: ${data.z}");
  }
});
```

この例では、「data」は通知からのデータを含むオブジェクトです。 「タイトル」フィールドと「メッセージ」フィールドには、それぞれ通知のタイトルとメッセージが含まれます。フィールド `w`、`x`、`y`、および `z` には追加のデータが含まれます。

### Checking for Updates (強制アップデート)

SDK は `checkForUpdates` メソッドを使用して更新の有無を確認できます。このメソッドは 3 つのオプションのパラメータを取ります。

- `useSDKDialog`: `true`を設定すると更新時にSDKダイアログを表示します。`false` の場合は表示しません。
- `onDismiss`: ユーザーがダイアログを閉じたときに呼び出されるコールバックを設定します。
- `onNavigationToStore`: ユーザーがストアに移動したときに呼び出されるコールバックを設定します。

使用方法の例を次に示します。

```dart
final result = await sdk.checkForUpdates(
    useSDKDialog: true,
    onDismiss: () {
      print("ユーザーがダイアログを閉じました");
    },
    onNavigationToStore: () {
      print("ユーザーがストアに移動しました");
    },
);
result.onSuccess((update) {
  print("Store URL: ${update.storeUrl}");
  print("更新は任意です: ${update.optional}");
});
result.onFailure((error) {
  print("更新の確認に失敗しました: ${error.message}");
});
```

この例では、更新をチェックし、結果を処理します。  
チェックが成功すると、ストアの URL と、更新がオプションであるかどうかが出力されます。チェックが失敗した場合は、エラー メッセージが出力されます。  

### ストアレビューをユーザにうながす

SDK の `requestAppReview` メソッドを使用して、ユーザーにアプリをレビューするよう求めることができます。  
このメソッドは、iOS と Android の両方でネイティブ アプリのレビュー ダイアログをトリガーします。

使用方法の例を次に示します。

```dart
sdk.requestAppReview();
```

この例では、`requestAppReview`メソッドを呼び出して、ユーザーにアプリのレビューを求めています。  
レビュー ダイアログの実際の表示はオペレーティング システムによって異なり、このメソッドが呼び出されたときに常に表示されるとは限らないことに注意してください。  

### Rich Push Notifications

この設定は iOS の場合にのみ必要です。 Android では、リッチ プッシュ通知のために追加の設定は必要ありません。

#### 通知サービス拡張機能の作成

通知サービス拡張機能を作成するには、次の手順に従います。

1. Xcode でプロジェクトを開きます。  
2. `File > New > Target…` と移動し、`Notification Service Extension` を選択します。  
3. 製品名を設定します。この例では、「NotificationServiceExtension」としています。
4. 'Project' と `Embed in Application` の両方で `Runner` を選択します。
5. `Finish`をクリックします。

以下の画像を参照してください。

![Notification Service Extension Creation](./assets/nse_creation.png)

これらの手順を完了した後、`Minimum Deployment Target` を `14.0` に設定します。  
次に、NotificationServiceExtensionターゲットの'Frameworks, Libraries, and Embedded Content'セクションにAppVisorSDK.xcframeworkを追加します。

![Notification Service Extension Target Configuration](./assets/nse_target_configuration.png)

次に、「NotificationService.swift」に移動し、既存のコードを次のコードに置き換えます。

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
    // 内線がシステムによって終了される直前に呼び出されます。
    // これを、変更されたコンテンツの「最善の試み」を配信する機会として使用します。そうでない場合は、元のプッシュ ペイロードが使用されます。
    if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }
}

```

#### 通知コンテンツ拡張機能の作成

通知コンテンツ拡張機能を作成するには、次の手順に従います。

1. Xcode でプロジェクトを開きます。
2. `File > New > Target…` と移動し `Notification Content Extension` を選択します。
3. `Product Name` フィールドに「NotificationContentExtensionImage」と入力します。
4. `Project` フィールドと「`Embed in Application`フィールドで、`Runner` を選択します。
5. `Finish`をクリックします。

  ![Notification Content Extension Creation](./assets/nce_creation.png)

6. `Deployment Info` セクションで、`Minimum Deployment Target` を `14.0` に設定します。  
7. `Frameworks, Libraries, and Embedded Content`セクションで、「+」ボタンをクリックし、`AppVisorSDK.xcframework`を追加します。  

  ![Notification Content Extension Target Configuration](./assets/nce_target_configuration.png)

8. `MainInterface.storyboard` に移動し、ビュー コントローラーから既存のビューを削除します。

  ![Notification Content Extension Main Interface](./assets/main_interface.png)

9. `Info.plist`をクリックし、`Information Property List > NSExtension > NSExtensionAttributes > UNNotificationExtensionCategory`に移動します。値を `NotificationViewController.swift`に設定します。
10. `NotificationViewController.swift` をクリックし、既存のコードを削除して次のコードに置き換えます。

```swift
import UIKit
import UserNotifications
import UserNotificationsUI
import AppVisorSDK

class NotificationViewController: UIViewController, UNNotificationContentExtension {

  override func viewDidLoad() {
    super.viewDidLoad()
    // 必要なインターフェイスの初期化をここで実行します。
  }
  
  func didReceive(_ notification: UNNotification) {
    Appvisor.sharedInstance.showImage(from: notification, in: self.view)
  }
}
```

これらの手順をさらに 2 回繰り返して、`NotificationContentExtensionVideo` と`NotificationContentExtensionWeb`を作成します。  

`NotificationContentExtensionVideo`の場合は、手順 3 で製品名として `NotificationContentExtensionVideo`を使用します。ステップ 9 で、値を`AppvisorRichPushMovieCategory`に設定します。ステップ 10 で、コードを次のように置き換えます。  

```swift
import UIKit
import UserNotifications
import UserNotificationsUI
import AppVisorSDK

class NotificationViewController: UIViewController, UNNotificationContentExtension {

  override func viewDidLoad() {
    super.viewDidLoad()
    // 必要なインターフェイスの初期化をここで実行します。
  }
  
  func didReceive(_ notification: UNNotification) {
    Appvisor.sharedInstance.showMovieRichPush(notification, in: self.view)
  }
}
```

`NotificationContentExtensionWeb`の場合、手順 3 で製品名として `NotificationContentExtensionWeb` を使用します。ステップ 9 で、値を`AppvisorRichPushCategory`に設定します。ステップ 10 で、コードを次のように置き換えます。

```swift
import UIKit
import UserNotifications
import UserNotificationsUI
import AppVisorSDK

class NotificationViewController: UIViewController, UNNotificationContentExtension {    
  override func viewDidLoad() {
    super.viewDidLoad()
    // 必要なインターフェイスの初期化をここで実行します。
  }
  
  func didReceive(_ notification: UNNotification) {
    Appvisor.sharedInstance.showWebSite(from: notification, in: self.view)
    self.preferredContentSize = CGSize(width: 320, height: 299)
  }
}
```
> :exclamation: **重要:**
> **"Cycle inside Runner; building could produce unreliable results…"** というエラーが発生した場合は、以下に示すようにランナーのビルド フェーズの順序を調整します。
>
> ![Build Phases](./assets/build_phases.png)


## Functions and Properties

| Function/Property | 説明 | パラメーター | Return Type |
| --- | --- | --- | --- |
| `deviceId` | デバイスの識別子。 | None | Future<String?> |
| `isPushEnabled` | プッシュが有効になっているかどうかを確認します。 | None | Future\<bool\> |
| `init(appKey, [enableLogs])` | SDKを初期化します。 | `appKey`: String, `enableLogs`: bool? | Future<Result<Null>> |
| `configure(channelName, channelDescription, smallIconName, [largeIconName, defaultTitle])` | オプションを使用して SDK を構成します。| `channelName`: String, `channelDescription`: String, `smallIconName`: String, `largeIconName`: String?, `defaultTitle`: String? | Future<Result<Null>> |
| `togglePush(enable)` | プッシュ通知を有効または無効にします。 | `enable`: bool | Future<Result<bool>> |
| `getCustomProperty(parameterId)` | カスタムプロパティを取得します。 | `parameterId`: int | Future\<String?\> |
| `setCustomProperty({required parameterId, value})` | カスタムプロパティを設定します。 | `parameterId`: int, `value`: String? | Future\<bool\> |
| `syncCustomProperties()` | カスタム プロパティをサーバーと同期します。 | None | Future<Result<Null>> |
| `checkForUpdate({useSDKDialog, onDismiss, onNavigationToStore})` | アップデートをチェックします。 | `useSDKDialog`: bool?, `onDismiss`: Function?, `onNavigationToStore`: Function? | Future<Result<UpdateData?>> |
| `requestAppReview()` | アプリのレビューをリクエストします。 | None | Future\<void\> |
| `getConfig()` | 設定を取得します。 | None | Future<Result<Map<String, dynamic>>> |
| `getNotices([lastKey])` | 通知を取得します。 | `lastKey`: LastKey? | Future<Result<NoticeList?>> |
| `markNoticeAsRead(messageId)` | 通知を既読としてマークします。 | `messageId`: int | Future<Result<Null>> |
| `notificationData` | 通知を受信するたびに通知からデータを出力するストリーム。| None | Stream\<NotificationData\>

## ブランチ運用

- `production`: 本番ブランチ。
- `staging`: ステージング ブランチ。
- `develop`: 開発ブランチ。

## ワークフロー

1. 「develop」ブランチで新機能と修正を開発します。.
2. テストの準備ができたら、変更を「staging」ブランチにマージし、タグを追加します。
3. 「develop」ブランチに修正が必要な場合は、それらを「staging」ブランチにマージします。
4. リリースの準備ができたら、「staging」ブランチを「production」ブランチにマージし、タグを追加します。

## プロジェクトのセットアップ中に発生した問題のメモ

プロジェクトのセットアップ中に、ローカルの `.aar` ライブラリを追加するときに問題が発生しました。この問題は、AAR を構築するときにローカルの `.aar` ファイルの直接の依存関係がサポートされていないことが原因でした。  
解決案は [StackOverflow](https://stackoverflow.com/questions/60878599/error-building-android-library-direct-local-aar-file-dependency-are-not-supp) で見つかりました。ただし、このソリューションを実装すると、この [Flutter GitHub の問題](https://github.com/flutter/flutter/issues/17150) に記載されているように、サンプル アプリの実行時に別の問題が発生しました。  

この二次的な問題は、同じ GitHub 問題スレッドの [このコメント](https://github.com/flutter/flutter/issues/17150#issuecomment-1249450980) で提案されている修正を使用して解決されました。
