import Foundation
import CoreLocation

class LocationSearchService: NSObject {
    private let geocoder = CLGeocoder()
    
    func searchLocation(address: String, completion: @escaping (Result<(latitude: Double, longitude: Double), Error>) -> Void) {
        // Add country/region bias for better results
        let geocodingRequest = "\(address)"
        
        geocoder.geocodeAddressString(geocodingRequest) { placemarks, error in
            if let error = error {
                let errorMessage: String
                switch (error as NSError).code {
                case 8: // Network error
                    errorMessage = "No se pudo conectar al servicio de búsqueda. Verifica tu conexión a internet. Dirección: \(address)"
                case 2: // Invalid address
                    errorMessage = "La dirección ingresada no es válida."
                default:
                    errorMessage = "Error al buscar la ubicación: \(error.localizedDescription)"
                }
                completion(.failure(NSError(domain: "LocationSearch", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }
            
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                completion(.failure(NSError(domain: "LocationSearch", code: -2, userInfo: [NSLocalizedDescriptionKey: "No se encontró la ubicación para esta dirección"])))
                return
            }
            
            completion(.success((latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)))
        }
    }
} 