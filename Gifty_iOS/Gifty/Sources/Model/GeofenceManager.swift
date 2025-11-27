import Foundation
import CoreLocation
import UserNotifications
import RealmSwift
import Realm

class GeofenceManager: NSObject {
    static let shared = GeofenceManager()

    private let locationManager = CLLocationManager()
    private let geofenceRadius: CLLocationDistance = 500
    var currentLocation: CLLocation?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
    }

    func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }

    func startMonitoring() {
        locationManager.startUpdatingLocation()
        setupGeofences()
    }

    func setupGeofences() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }

        let gifts = RealmManager.shared.getGifts()

        for gift in gifts {
            guard let latitude = gift.latitude,
                  let longitude = gift.longitude,
                  !gift.isExpired else { continue }

            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = CLCircularRegion(
                center: center,
                radius: geofenceRadius,
                identifier: gift.id.stringValue
            )

            region.notifyOnEntry = true
            region.notifyOnExit = false

            locationManager.startMonitoring(for: region)
        }
    }

    func addGeofence(for gift: Gift) {
        guard let latitude = gift.latitude,
              let longitude = gift.longitude else { return }

        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = CLCircularRegion(
            center: center,
            radius: geofenceRadius,
            identifier: gift.id.stringValue
        )

        region.notifyOnEntry = true
        region.notifyOnExit = false

        locationManager.startMonitoring(for: region)
    }

    func removeGeofence(for giftId: String) {
        if let region = locationManager.monitoredRegions.first(where: { $0.identifier == giftId }) {
            locationManager.stopMonitoring(for: region)
        }
    }

    func isGiftNearby(_ gift: Gift) -> Bool {
        guard let currentLocation = currentLocation,
              let giftLat = gift.latitude,
              let giftLon = gift.longitude else {
            return false
        }

        let giftLocation = CLLocation(latitude: giftLat, longitude: giftLon)
        let distance = currentLocation.distance(from: giftLocation)

        return distance <= geofenceRadius
    }

    private func sendNotification(for gift: Gift) {
        let content = UNMutableNotificationContent()
        content.title = "🎁 교환권 사용 알림"
        content.body = "'\(gift.name)' 사용처가 근처에 있어요! (500m 이내)"
        content.sound = .default
        content.userInfo = ["giftId": gift.id.stringValue]

        let request = UNNotificationRequest(
            identifier: "geofence_\(gift.id.stringValue)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}

extension GeofenceManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }

        if let gift = RealmManager.shared.getGift(by: region.identifier) {
            sendNotification(for: gift)

            NotificationCenter.default.post(
                name: NSNotification.Name("NearbyGiftDetected"),
                object: nil,
                userInfo: ["giftId": gift.id.stringValue]
            )
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        NotificationCenter.default.post(
            name: NSNotification.Name("NearbyGiftUpdated"),
            object: nil
        )
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            startMonitoring()
        case .denied, .restricted:
            break
        case .notDetermined:
            requestLocationPermission()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    }
}
