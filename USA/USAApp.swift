import SwiftUI
import Sentry

import UIKit
import Firebase
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import FirebaseFirestore

class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SentrySDK.start { options in
            options.dsn = "https://582c6a5129c8e2f0d3bcc8002a2ae6dc@o4507734083502080.ingest.us.sentry.io/4507734092152832"
            options.debug = true // Enabled debug when first installing is always helpful
            options.sampleRate = 1.0

            // Uncomment the following lines to add more data to your events
            // options.attachScreenshot = true // This adds a screenshot to the error events
            // options.attachViewHierarchy = true // This adds the view hierarchy to the error events
        }

        // Configure Firebase
        FirebaseApp.configure()
        
        // Set up Firebase Messaging delegate
        Messaging.messaging().delegate = self
        
        // Register for remote notifications
        registerForPushNotifications(application: application)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func saveFcmTokenToFirestore(userId: String, token: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        // Set the FCM token field
        userRef.setData(["fcmToken": token], merge: true) { error in
            if let error = error {
                print("Error writing FCM token to Firestore: \(error)")
            } else {
                print("FCM token successfully written to Firestore.")
            }
        }
    }
    
    private func registerForPushNotifications(application: UIApplication) {
        // Set this class as the delegate for notification center
        UNUserNotificationCenter.current().delegate = self
        
        // Request authorization for notifications
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            print("Permission granted: \(granted)")
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    // Handle incoming notification settings
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .list, .sound])
    }
    
    // Handle Firebase registration token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken, let userId = Auth.auth().currentUser?.uid else {
            print("No FCM token or user is not logged in")
            return
        }
        
        // Proceed to save the FCM token with the user ID
        saveFcmTokenToFirestore(userId: userId, token: token)
    }
}


@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var viewModel = TripsViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(viewModel)
        }
    }
}
