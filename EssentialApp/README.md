NetworkModularisation
![ModelDigram](https://github.com/shilpabansal/NetworkModularisation/blob/main/ModalDiagram.png)
![FlowChart](https://github.com/shilpabansal/NetworkModularisation/blob/main/FlowChart.png)

[![Build Status](https://travis-ci.com/shilpabansal/NetworkModularisation.svg?branch=main)](https://travis-ci.com/shilpabansal/NetworkModularisation)

________________________________________________________________________________________

The localizedString works similar to dictionary with key value pair, if it can not find the key in the file, it returns the key itself as value.
The table is the file name
________________________________________________________________________________________






________________________________________________________________________________________
Modularising the network project with TDD

 Instead of creating success and error object, its always better to create an enum to have less maintenance for diff kinds of result, as at a time it will be only one kind of result
 
 Network library is unaware of common errors and responses, the viewmodel receives the respoonse and convert it into the expected enum responses which can be handled by the views
 
 As the data expected from Api has image as the key name and the the param name is imageURL in FeedItem
 To keep FeedItem generic in RemoteFeedLoader the mapping is done to avoid the changes in the FeedLoader module on API change
 
 For requestURLs an array is taken in order to track how many reqquests are made and in what order they are made
 
 By default struct's default initialiser is internal, if it needs to be used outside module, it has to be provided explicitly

Importing testable module, benefits by taking internal entities also
________________________________________________________________________________________


________________________________________________________________________________________
URLProtocol:

Intercepting/mocking network request
Every time we perform URLRequest, there is URL Loading system to handle those requests.
As part of URL Loading system, there is an abstract class class URLProtocol which inherits from NSObject. 
If we create our own class subclassing URLProtocol and register it, we can start intercepting URL requests.

All we have to do is, implement Abstract method of URLProtocol class

For eg. for the test cases, we can intercept the request so we never go to cloud. It doesn’t matter which network library we are using AFNetworking, Maya or something else.

NSURLProtocolClient provides the interface to the URL loading system, the HTTPProtocol abstract class has instance of it.
________________________________________________________________________________________








________________________________________________________________________________________
App Transport Security

App Transport Security blocks every request that is made over HTTP and enforces a number of rules for requests that are made over HTTPS. Apple added App Transport Security to improve the privacy and security of applications that connect to the web. App Transport Security blocks every request that is made over an insecure connection. With requests made over HTTP as long as you realize that the data is sent as cleartext and that is by definition insecure. With App Transport Security, Apple attempts to convince or encourage developers to make their applications more secure by making secure connections the default.
More details: https://cocoacasts.com/app-transport-security-has-blocked-my-request
________________________________________________________________________________________










________________________________________________________________________________________
Continous integration using travis

Check below commands using command line to see if command is working fine
1. To check simulator and sdk details:         xcodebuild -showsdks
2. xcodebuild clean build test -project NetworkModularization.xcodeproj -scheme "CI" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphonesimulator14.3 -destination 'platform=iOS Simulator,name=iPhone 12 Pro Max,OS=14.3'



3. Create .travis.yml file:             touch .travis.yml

4. Put below content in  .travis.yml
    os: osx
    osx_image: xcode12.3
    langauge: swift
    script: xcodebuild clean build test -project NetworkModularization.xcodeproj -scheme "CI" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphonesimulator14.3 -destination 'platform=iOS Simulator,name=iPhone 12 Pro Max,OS=14.3'


5. signed up travis account
6. link with github
7. Push travis config file to git repo

whenever there will be any push to git repo, travis job will be started



________________________________________________________________________________________
If thread sanitisation is enabled, it detects the data race. 
A data race occurs when two or more thread access the same memory location concurrently without synchronisation and at least one access is a write.

In  test method test_getFromURL_performGetRequestFromURL
 As there is no wait for expectation for async call, the tear down method(main thread) is making stub as nil, where as stub call in URLProtolcolStub  class( via loadFeeds(background thread)) is trying to access stub. Therefore data race condition occurs.

To solve this, set expectationFulFillmentCount to 2, which will expect expectation to be called twice.
________________________________________________________________________________________






________________________________________________________________________________________

URLSession has a singleton shared session (which doesn’t have a configuration object) for basic requests. It’s not as customizable as sessions you create, but it serves as a good starting point if you have very limited requirements. You access this session by calling the shared class method. For other kinds of sessions, you create a URLSession with one of three kinds of configurations:

A default session behaves much like the shared session, but lets you configure it. You can also assign a delegate to the default session to obtain data incrementally.

Ephemeral sessions are similar to shared sessions, but don’t write caches, cookies, or credentials to disk.

Background sessions let you perform uploads and downloads of content in the background while your app isn't running.


It’s common to see iOS codebases using SCNetworkReachability, NWPathMonitor, or third-party reachability frameworks to make decisions about whether they should make a network request or not. Unfortunately, such a process is not reliable and can lead to bad customer experience.

As advised by Apple, we can use the reachability status to diagnose the cause of the failure and perform actions after a failed request. For example, you can automatically retry a failed request on a reachability callback. You can also use the current reachability status to display hints to the user, such as "Looks like you're offline." But you shouldn’t stop attempting to make a request based on the current reachability status.


waitsForConnectivity
If you use URLSession to make a data task while the user has no internet connection, your request will fail immediately and report an error. However, if you create your session with the waitsForConnectivity configuration option set to true, then the system will automatically wait some time to see if connectivity becomes available before trying the request.
For example, this creates a data task that fetches a URL only when internet connectivity is available:
let config = URLSessionConfiguration.default
config.waitsForConnectivity = true

URLSession(configuration: config).dataTask(with: yourURL) { data, response, error in
    if let error = error {
        print(error.localizedDescription)
    } ei

    // use your data here
}.resume()
By default, the system will wait seven days to see if internet connectivity becomes available, but you can control that with the timeoutIntervalForResource property on your configuration. For example, this will ask the system to wait 60 seconds:
config.timeoutIntervalForResource = 60


This property is ignored by background sessions, which always wait for connectivity.
________________________________________________________________________________________






________________________________________________________________________________________
Low data mode:
When n/w is expensive, app should be using the data conservatively 

URLSession/URLConfiguration have property  allowsConstrainedNetworkAccess
iOS lets users enable Low Data Mode for any cellular or WiFi connection, which signals to apps that they should be careful how much data they use. This might mean downloading lower-resolution images, it might mean disabling prefetching, or some other way of cutting down on bandwidth use.

By default your app does not honour the user’s low data mode setting, but you can change that by setting the allowsConstrainedNetworkAccess property to false for a given URLRequest. For example:
var request = URLRequest(url: someURL)
request.allowsConstrainedNetworkAccess = false
When that request executes iOS will immediately return an error if low data mode is enabled, which might be your cue to do another request for less data or lower-resolution images, for example. You can detect this error by typecasting it to a URLError, then checking if the networkUnavailableReason property is set to .constrained:

if let error = error as? URLError, error.networkUnavailableReason == .constrained {
    // user has activated low data mode so this request could not be satisfied
}
_______________________________________________________________________________________







________________________________________________________________________________________
allowsExpensiveNetworkAccess: 
There is a similarly named URLSession property called allowsExpensiveNetworkAccess, which determines whether network requests can be made over a personal hotspot. It’s considered expensive because often users on cellular networks have lower data caps.


Instead of limiting the network call for cellular its better to check for expensive property, which system gives, currently it checks for cellular or hotspot. 
________________________________________________________________________________________





________________________________________________________________________________________
multipathServiceType
A service type that specifies the Multi-path TCP connection policy for transmitting data over Wi-Fi and cellular interfaces.

Multipath TCP, is an extension to TCP that permits multiple interfaces to transmit a single data stream. This capability allows a seamless handover from Wi-Fi to cellular, aimed at making both interfaces more efficient and improving the user experience.
The multipathServiceType property defines which policy the Multipath TCP stack uses to schedule traffic across Wi-Fi and cellular interfaces. The default value is none, meaning Multipath TCP is disabled. You can also select handover mode, which provides seamless handover between Wi-Fi and cellular.
________________________________________________________________________________________






________________________________________________________________________________________
By default HTTP and HTTPs requests are cached in memory and disk using URLCache class
default shared instance has 4MB memory capacity and 20MB disk capacity

 The disk and memory size can be increaed for cache.
 in case we want to increase, it should be done in didFinishLoading to avoid inconsistent caching
 
 let cache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
 configuration.urlCache =  URLSessionConfiguration.default 
 let session = URLSession(configuration: configuration)
 URLCache.shared = cache
 ________________________________________________________________________________________




________________________________________________________________________________________
To check the default location of the caches
let documentsUrl =  fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first! as NSURL
let documentsPath = documentsUrl.path
print(documentsPath)

By default URLSession's shared object has caching available, if the data shouldn't be cached, ephemeral object can be used

the max age for cache policy can be changed.
________________________________________________________________________________________




________________________________________________________________________________________
The default caching is only done if below are true:
1. the request is HTTP/HTTPs or custom n/wing protocol that support caching
2. The request is successful, status code 200-299 range
3. Provided response came from server, not the cache
4. session config allows caching
5. The provided URLRequest object's cache policy allows caching
6. Cache header in the server's response allows caching
7. The response size is small enough to reaonably fit in cache
________________________________________________________________________________________





________________________________________________________________________________________

As all the modules are tightly coupled with FeedItem, if there is any change in FeedItem, all modules will need to changes.

To avoid this, we should be trying to decouple the modules as much as possible.
________________________________________________________________________________________







________________________________________________________________________________________
Core Data

As the requirement is to store Feeds with timestamp, created  two entities  Feed and Cache in the FeedStoreDataModel

Steps:

    Feed has properties id, imageDescription, url and location. The values can be made optional and non-optional based on the need
    Cache has property timestamp
    As there will be only one cache with multiple feed entries. created one-to-many relationship from cache to Feed.
    Made the relationship as ordered, as the feeds should be stored in the sequential manner

    Select the entity -> Editor -> Create NSManagedObject Subclass, properties and relationship files will be created automatically
    By-default the one to many relationship property is stored in NSSet but as its ordered, NSOrderedSet is created
    Updated the one-to-many relationship's delete rule as "Cascasde", so that on deletion of cache, feeds are deleted

    To load the persistent container, it needs the production bundle name with the datamodel filename

![FlowChart](https://github.com/shilpabansal/NetworkModularisation/blob/main/FetchRequest.png)

When performing operations on an NSManagedObjectContext instance make sure to execute the operations on the queue specified for the context by enclosing in them in a perform(_:) closure block. NSManagedObjectContext.perform executes the block on its own thread, which is imperative for not causing possible multi-thread concurrency issues.

NSManagedObjectContext.perform returns immediately, executing the closure asynchronously. The synchronous variation of the perform method comes with the NSManagedObjectContext.performAndWait method. In this case, the context still executes the closure block on its own thread, but the method doesn’t return until the block is executed.

NSFetchRequest has a property “returnsObjectsAsFaults” which return faulty objects.

Faulting is one of the techniques that core data uses to keep its memory low without sacrificing performance and also decreases the fetch objects response time. The idea is simple, only load data when it’s needed.
Let’s suppose we have Entity A contains 100 attributes / properties . In persistent store we have 1000 records of Entity A was saved . When we fetched all data normally it will load all 1000 data in a cache(NSManagedObjectContext) each having 100 properties which takes time and also consumes memory.
If we do lazy loading or ask Managed Object Context to fetch data in faults What it will do it will return 1000 records metadata information (contains information for tracking) only which will be very fast and will not take much memory.
Note: When loading data using fault no property will instantiated or loaded into memory only meta data will load that can track object in a persistent store
Now when client tries to access property on first record of faulty Entity A object.It will load complete instance of that record with all the properties of particular record that was accessed which means 999 records still in faulty state only the record that was accessed will be loaded and we term that is used fault is fired.

You can set returnsObjectsAsFaults to false to gain a performance benefit if you know you will need to access the property values from the returned objects immediately. In short if you want to fetch objects and immediately populate fields there is no purpose of lazy loading at that time. Since firing a fault relative to normal could be expensive.

![FlowChart](https://github.com/shilpabansal/NetworkModularisation/blob/main/ObjectAsFault.png)

let fetchRequest = NSFetchRequest<ManagedFeed>(entityName: "ManagedFeed")

Predicate
    fetchRequest.predicate = NSPredicate(format: "location == %@", "test")
    
Sort:
    let sortDescriptor = NSSortDescriptor.init(key: "id", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
Using propertiesToFetch array type property in NSFetchRequest we tell Managed Object Context to bring only these properties.
    fetchRequest.propertiesToFetch = ["location"]

Limit the Fetch Results
    The fetch limit specifies the maximum number of objects that a request should return when executed.
    fetchRequest.fetchLimit = 1
    
Batching Core Data
    Suppose we are executing a fetch request that returns about 2000 entities. which, is taking about 20 seconds on a device. We can set a fetch limit of 100, and then when the user scrolls to the end of the table view, fetch the next 20 entities. This can be accomplished using NSFetchRequest's setFetchLimit and setFetchOffset
    fetchRequest.fetchOffset += 20
    fetchRequest.fetchLimit = 100

Pointing the store at /dev/null
The null device discards all data directed to it while reporting that write operations succeeded.

By using a file URL of /dev/null for the persistent store, the Core Data stack will not save SQLite artifacts to disk, doing the work in memory. This means that this option is faster when running tests, as opposed to performing I/O and actually writing/reading from disk. Moreover, when operating in-memory, you prevent cross test side-effects since this process doesn’t create any artifacts.

Persistent Store Types
 NSSQLiteStoreType:  The SQLite database store type.
 NSXMLStoreType :   The XML store type.
NSBinaryStoreType: The binary store type.
NSInMemoryStoreType: The in-memory store type.

________________________________________________________________________________________







________________________________________________________________________________________

An insightful indicator for measuring the codebase exposure to mutability is the number of assignable variable declarations (var).

Assignable var statements imply mutable state.

Mutable state is tough to maintain as the complexity to manage mutable state tends to grow out of control as you add more features to your applications. That’s why we recommend you to avoid creating a design where mutable state is present at every layer. Use immutable state as much as you can!

Of course, at some point, you need to mutate state. However, as explained in the Functional Core/Imperative Shell lecture, we strive to limit mutation to the boundaries of the system (where we recommend you to keep frameworks like Core Data, Realm, Firebase). Doing so makes testing and state management much simpler, safer, and easier.
________________________________________________________________________________________







________________________________________________________________________________________
Result in Swift 5

1. Result has a get() method that either returns the successful value if it exists, or throws its error otherwise. This allows you to convert Result into a regular throwing call, like this:

fetchUnreadCount1(from: "https://www.hackingwithswift.com") { result in
    if let count = try? result.get() {
        print("\(count) unread messages.")
    }
}

2. you can use regular if statements to read the cases of an enum if you prefer. For example:

fetchUnreadCount1(from: "https://www.hackingwithswift.com") { result in
    if case .success(let count) = result {
        print("\(count) unread messages.")
    }
}

3.  Result has an initializer that accepts a throwing closure: if the closure returns a value successfully that gets used for the success case, otherwise the thrown error is placed into the failure case.

For example:

let result = Result { try String(contentsOfFile: someFile) }
Fourth, rather than using a specific error enum that you’ve created, you can also use the general Error protocol. In fact, the Swift Evolution proposal says “it's expected that most uses of Result will use Swift.Error as the Error type argument.”

So, rather than using Result<Int, NetworkError> you could use Result<Int, Error>. Although this means you lose the safety of typed throws, you gain the ability to throw a variety of different error enums – which you use really depends on your preferred coding style.

Finally, if you already have a custom Result type in your project – anything you have defined yourself or imported from one of the custom Result types on GitHub – then they will automatically be used in place of Swift’s own Result type. This will allow you to upgrade to Swift 5.0 without breaking your code, but ideally you’ll move to Swift’s own Result type over time to avoid incompatibilities with other projects.

________________________________________________________________________________________







________________________________________________________________________________________

prepareForReuse
If a UITableViewCell object is reusable—that is, it has a reuse identifier—this method is invoked just before the object is returned from the UITableView method dequeueReusableCell(withIdentifier:). For performance reasons, you should only reset attributes of the cell that are not related to content, for example, alpha, editing, and selection state. The table view's delegate in tableView(_:cellForRowAt:) should always reset all content when reusing a cell. If the cell object does not have an associated reuse identifier, this method is not called. If you override this method, you must be sure to invoke the superclass implementation.
________________________________________________________________________________________







________________________________________________________________________________________
![DesignPatterns](https://github.com/shilpabansal/NetworkModularisation/blob/main/DesignPatterns.png)
MVC:  Model view controller
Model and view are dummy entities, controller control logic, n/w calls, notification, actions etc



MVVM: Model view viewModel
Model and View are dummy
ViewController: takes the action and pass it to viewModel
ViewModel: handles n/w calls, parsing, logic etc and returns it to viewcontroller via blocks or closures.

ViewModel can be stateful/stateless based on the requirements
if there are very limited data to maintain -> it can call the closures of VC
If there are a lot of data passing, states can be created and VC can have listeners to those state changes

If the project is built for multiple platforms like watchKit, iOS, Mac etc. ViewModel can be shared amond them but VC has to be created for each platform.
![MVVM](https://github.com/shilpabansal/NetworkModularisation/blob/main/MVVM.png)



MVP: Model view Presenter
Controller is similar to presenter


In MVC, controller holds the reference to concrete type view, In MVP Presenter holds the reference to abstract view type in the form of protocol

ViewProtocol belongs to Presenter, 

IN MVP, View doesnt know about the controller, in MVP View directly communicates with Presenter. Its 2 way communication. Presenter directly talks with domain model and services, formats the model view before passing it to view. But the more risk of memory leak is involved.

In MVVM, the view model have data states and control the states. where as in MVP, VM only keeps the data states, doesnt control them
![MVP](https://github.com/shilpabansal/NetworkModularisation/blob/main/MVP.png)


Presenter implemetation protocol belongs to presenatation model, so it doesnt depend on the specific of UI frameworks or platforms

There cab be many variations of MVP based on the needs. Its possible for view to decouple from presenatation layer.
________________________________________________________________________________________







________________________________________________________________________________________
1. As UIKit is not thread safe, all the UI updation needs to be handled in main thread
2. Though the logic can be directly handled in DispatchQueue.main, there are chances that we are already in main thread, to check it below code can be added.
if Thread.isMainThread {}
else { DipatchQueue.main.async{}}

3. If Threading logic is added in UIViewController, there will be a lot of duplicacy, to avoid it, it can be moved to one layer up. Like presenter. But As presenter layer is unaware of UI logic, its better to move it to composer layer.
4. A decoorator can be added, which moved the code from background to main thread and it can be created with generic implementation to avoid duplicate decorators
________________________________________________________________________________________







________________________________________________________________________________________
UI Test with launch argument/environments

If not modified, these are the arguments that Xcode will pass to the application on launch. The arguments can be changed, added to, or removed. Such changes will not affect the current launch session, but will take effect the next time the application is launched.


launch arguments can be appended in the array and check at run time. 

1. let app = XCUIApplication()
    app.launchArguments = ["debug"]
    app.launch()

2. let app = XCUIApplication() 
    app.launchArguments = ["-connectivity", "offline"]
    app.launch()
    In above case connectivity is considered as key and value as offline.


Launch argument can be read in below ways:
1. CommandLine.arguments.contains("debug")
2. ProcessInfo.processInfo.arguments.contains("debug")
3. To read the key value pair from arguments:
    UserDefaults.standard.bool(forKey: "connectivity")



Launch environment:
It only accepts the value as dictionary:
    let app = XCUIApplication()<font></font>
    app.launchEnvironment = ["server":"52.91.241.56"]
    app.launch()
    
Reading
    var singupURL = ProcessInfo.processInfo.environment["signupUrl"]
