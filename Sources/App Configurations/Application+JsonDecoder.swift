import Vapor

extension Application {
    // Función factoría para evitar copiar la configuración
    static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }
    
    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }
    
    // Propiedades que crean siempre uno nuevo
    var myJSONEncoder: JSONEncoder { Self.makeEncoder() }
    var myJSONDecoder: JSONDecoder { Self.makeDecoder() }
    
    func setJsonDecoder() {
        // Aquí sí puedes usar una instancia cualquiera, porque
        // ContentConfiguration.global solo necesita leer la configuración.
        ContentConfiguration.global.use(encoder: Self.makeEncoder(), for: .json)
        ContentConfiguration.global.use(decoder: Self.makeDecoder(), for: .json)
    }
}

extension Request {
    var myJSONEncoder: JSONEncoder { self.application.myJSONEncoder }
    var myJSONDecoder: JSONDecoder { self.application.myJSONDecoder }
}

