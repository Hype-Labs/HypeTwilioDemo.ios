
![alt tag](https://hypelabs.io/static/img/NQMAnSZ.jpg)
![alt tag](https://hypelabs.io/static/img/logo200x.png)

[Hype](http://hypelabs.io/?r=9) is a SDK for cross-platform peer-to-peer communication with mesh networking. Hype works even without Internet access, connecting devices via other communication channels such as Bluetooth, Wi-Fi direct, and Infrastructural Wi-Fi.

The Hype SDK has been designed by [Hype Labs](http://hypelabs.io/?r=9). It is currently in private Beta for iOS  and [Android](https://github.com/Hype-Labs/HypeChatDemo.android).

You can start using Hype today, [join the beta by subscribing on our website](http://hypelabs.io/?r=9).

## What does it do?

This project consists of a chat app sketch written to illustrate an integration between two technology's, Hype framework and Twilio iOS SDK.
This demo allows users to communicate with a public chat room even if they don't have internet access.

Most of Hype documentation is inline with the code, and further information can be found on the Hype Labs [official documentation site](https://hypelabs.io/docs/).

## Setup Hype Framework

The first thing you need is the Hype SDK binary. Subscribe for the Beta program at the Hype Labs [website](http://hypelabs.io/downloads/) and follow the instructions from your inbox. You'll need your subscription to be activated before proceeding.

#### 1. Add the SDK to your Xcode project

Hype is really easy to configure! Open the project with Xcode and drag the binary into the project in the Project Navigator. Also see [Apple's documentation page](https://developer.apple.com/library/ios/recipes/xcode_help-structure_navigator/articles/Adding_a_Framework.html) with details and alternative solutions. Some versions of Xcode require adding the framework to Embedded Binaries in the project's General configurations.

#### 2. Register an app

Go to [the apps page](http://hypelabs.io/apps) and create a new app by pressing the _Create new app_ button on the top left. Enter a name for your app and press Submit. The app dialog that appears afterwards yields a 8-digit hexadecimal number, called _app identifier_. Keep that number for step 3 . App identifiers are a mean of segregating the network, by making sure that different apps do not communicate with each other, even though they are capable of forwarding each other's contents. If your project requires a deeper understanding of how the technology works we recommend reading the [Overview](http://hypelabs.io/docs/ios/overview/) page. There you'll find a more detailed analysis of what app identifiers are and what they do, as well as other topics about the Hype framework.

#### 3. Setup the app identifier

The app identifier must be set in the project's Info.plist file or before starting the Hype services. You'll find your Info.plist in Project Navigator under the Supporting Files group. If you are not sure how to edit your Info.plist, we recommend reading Apple's documentation [here](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html) for that regard. Add a new top level entry on your Info.plist called _com.hypelabs.hype_ and set its type to _Dictionary_. Expand the entry by clicking on the arrow on the left and replace the _New item_ text with _appIdentifier_. Set its type to _String_ and the value to the identifier that you got from step 2. Alternatively, you can set it using the method `setAppIdentifier`, before starting the framework's services, with an `NSString` value indicating the identifier. The following example illustrates how to do this. The 00000000 identifier is reserved for testing purposes and apps should not be deployed with it. Also, setting the app identifier with `setAppIdentifier:` takes precedence over the identifier read from the Info.plist file.

```objc
    [HYP setAppIdentifier:@"00000000"];
```

## Setup Twilio SDK

The first thing we need to do is grab all the necessary configuration values from our
Twilio account. To set up our back-end for Chat, we will need four 
pieces of information:

| Config Value  | Description |
| :-------------  |:------------- |
Service Instance SID | Like a database for your Chat data - [generate one in the console here](https://www.twilio.com/console/chat/services)
Account SID | Your primary Twilio account identifier - find this [in the console here](https://www.twilio.com/console/chat/getting-started).
API Key | Used to authenticate - [generate one here](https://www.twilio.com/console/chat/dev-tools/api-keys).
API Secret | Used to authenticate - [just like the above, you'll get one here](https://www.twilio.com/console/chat/dev-tools/api-keys).

## Set Up The Server App

A Chat application has two pieces - a client (our iOS app) and a server.
You can learn more about what the server app does [by going through this guide](https://www.twilio.com/docs/api/chat/guides/identity).
For now, let's just get a simple server running so we can use it to power our
iOS application.

[Download server app](https://www.twilio.com/docs/quickstart/client/ios#download-configure-and-run-the-starter-app)

Unzip the app you just downloaded, and follow the instructions of the language you choossen.

To confirm everything is set up correctly, visit [http://localhost:8000/chat/](http://localhost:8000/chat/)
in a web browser. You should be assigned a random username, and be able to enter
chat messages in a simple UI that looks like this:

![quick start app screenshot](https://s3.amazonaws.com/howtodocs/quickstart/ipm-browser-quickstart.png)

Feel free to open this app up in a few browser windows and chat with yourself! You
might also find this browser app useful when testing your iOS app, giving you an
easy second screen to send chat messages. Leave this server app running in the Terminal 
so that your iOS app running in the simulator can talk to it.

Now that our server is set up, let's get the starter iOS app up and running.

## PLEASE NOTE

The source code in this application is set up to communicate with a server
running at `http://localhost:5000`. If you run this project on a device, 
it will not be able to access your token server on `localhost`.

To test on device, your server will need to be on the public Internet. For this,
you might consider using a solution like [ngrok](https://ngrok.com/). You would
then update the `localhost` URL in the `ViewController` with your new public
URL.

## Configure and Run the Mobile App

Our mobile application manages dependencies via [Cocoapods](https://cocoapods.org/).
Once you have Cocoapods installed, download or clone this application project to
your machine.  To install all the necessary dependencies from Cocoapods, run:

```
pod install
```

Open up the project from the Terminal with:

```
open ChatQuickstart.xcworkspace
```

Note that you are opening the `.xcworkspace` file rather than the `xcodeproj`
file, like all Cocoapods applications. You will need to open your project this
way every time. You should now be able to press play and run the project in the 
simulator. Assuming your PHP backend app is running on `http://localhost:8000`, 
there should be no further configuration necessary.

Once the app loads in the simulator, you should see a UI like this one:

![quick start app screenshot](https://s3.amazonaws.com/howtodocs/ios-quickstart/iphone.png)

Start sending yourself a few messages - they should start appearing both in a
`UITableView` in the starter app, and in your browser as well if you kept that
window open.

You're all set! From here, you can start building your own application. For guidance
on integrating the iOS SDK into your existing project, [head over to our install guide](https://www.twilio.com/docs/api/chat/sdks).
If you'd like to learn more about how Chat works, you might want to dive
into our [user identity guide](https://www.twilio.com/docs/api/chat/guides/identity), 
which talks about the relationship between the mobile app and the server.


## License

MIT
