import CoreLocation
import MapKit

struct LocationResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
}

@MainActor
class LocationSearchService: ObservableObject {
    @Published private(set) var searchResults: [LocationResult] = []
    @Published private(set) var isSearching = false
    private let searchCompleter = MKLocalSearchCompleter()
    private var currentSearch: MKLocalSearch?
    
    init() {
        searchCompleter.resultTypes = .address
    }
    
    func searchLocations(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        do {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.resultTypes = .address
            
            currentSearch?.cancel()
            let search = MKLocalSearch(request: request)
            currentSearch = search
            
            let response = try await search.start()
            
            searchResults = response.mapItems.map { item in
                LocationResult(
                    title: item.name ?? "",
                    subtitle: item.placemark.title ?? "",
                    coordinate: item.placemark.coordinate
                )
            }
        } catch {
            print("Search error: \(error.localizedDescription)")
            searchResults = []
        }
        
        isSearching = false
    }
    
    func cancelSearch() {
        currentSearch?.cancel()
        searchResults = []
        isSearching = false
    }
}
