import Fluent
import Vapor
struct ImageUrlController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let imageUrl = routes.grouped("imageUrls")
        imageUrl.post("sync", use: sync)
        imageUrl.get(":imageId", use: serveImage)
        imageUrl.post(use: save)
    }
    func sync(req: Request) async throws -> [ImageURLDTO] {
        let request = try req.content.decode(SyncImageParameters.self)
        
        let query = ImageUrl.query(on: req.db)
            .filter(\.$updatedAt >= request.updatedSince)
            .sort(\.$updatedAt, .ascending)
            .limit(50)
        
        let images = try await query.all()
        
        return images.mapToListImageURLDTO()
    }
    func serveImage(req: Request) throws -> Response {
        print("New service OK 2.0")
        // Extraer el UUID de la URL
        guard let imageIdS = req.parameters.get("imageId") else {
            throw Abort(.badRequest, reason: "No image ID provided")
        }
        guard let imageId = UUID(uuidString: imageIdS) else {
            throw Abort(.badRequest, reason: "El id es invalido")
        }
        guard fileExists(id: imageId) else {
            throw Abort(.notFound, reason: "Image not found")
        }
        // Ruta donde se almacenan las imágenes en el servidor
        let imageDirectory = getPathById(id: imageId)
        // Crear la respuesta con el contenido de la imagen
        return req.fileio.streamFile(at: imageDirectory)
    }
    func save(req: Request) async throws -> ImageURLDTO {
        let imageUrlDto = try req.content.decode(ImageURLDTO.self)
        //No se permite edicion de ImagenUrl, en todo caso crear uno nuevo
        if let imageUrl = try await ImageUrl.find(imageUrlDto.id, on: req.db) {
            return imageUrl.toImageUrlDTO()
        } else if let imageData = imageUrlDto.imageData { //Si hay imageData entonces guardara imagen local
            guard imageUrlDto.imageHash != "" else {
                throw Abort(.badRequest, reason: "Se debe proporcionar el hash")
            }
            if let imageUrl = try await getImageUrlByHash(hash: imageUrlDto.imageHash, req: req) {
                print("1: Se encontro por Hash")
                return imageUrl.toImageUrlDTO()
            } else if imageUrlDto.imageUrl != "", let imageUrl = try await getImageUrlByUrl(url: imageUrlDto.imageUrl, req: req) {
                print("1: Se encontro por Url")
                return imageUrl.toImageUrlDTO()
            } else {
                print("1: Se Creara que mrd")
                //Create
                let imageUrlNew = ImageUrl(
                    id: imageUrlDto.id,
                    imageUrl: getDomainUrl() + "imageUrls/" + imageUrlDto.id.uuidString,
                    imageHash: imageUrlDto.imageHash
                )
                print("Id de la imagen creada: \(String(describing: imageUrlNew.id))")
                //Crear nueva ImagenUrl
                if !fileExists(id: imageUrlNew.id!) {
                    print("Se guardara en local")
                    //Save imageData in localStorage
                    try createFile(id: imageUrlNew.id!, imageData: imageData)
                    guard fileExists(id: imageUrlNew.id!) else {
                        throw Abort(.badRequest, reason: "Se verifico que la imagen creada no existe")
                    }
                }
                try await imageUrlNew.save(on: req.db)
                return imageUrlNew.toImageUrlDTO()
            }
        } else if imageUrlDto.imageUrl != "" { //Si no hay imageData debe tener URL
            guard imageUrlDto.imageUrl != "" else {
                throw Abort(.badRequest, reason: "Se debe proporcionar el la url")
            }
            if let imageUrl = try await ImageUrl.find(imageUrlDto.id, on: req.db) {//No actualizamos nada si busca por id
                print("2: Se encontro por Id")
                return imageUrl.toImageUrlDTO()
            } else if imageUrlDto.imageHash != "", let imageUrl = try await getImageUrlByHash(hash: imageUrlDto.imageHash, req: req) {
                print("2: Se encontro por hash")
                return imageUrl.toImageUrlDTO()
            } else if let imageUrl = try await getImageUrlByUrl(url: imageUrlDto.imageUrl, req: req) {
                print("2: Se encontro por Url")
                return imageUrl.toImageUrlDTO()
            } else {
                print("2: Se creara")
                //Create
                let imageUrlNew = imageUrlDto.toImageUrl()
                try await imageUrlNew.save(on: req.db)
                return imageUrlNew.toImageUrlDTO()
            }
        } else {
            throw Abort(.badRequest, reason: "Se debe proporcionar el ImageData con hash o Url")
        }
    }
    private func getPathById(id: UUID) -> String {
        let filename = id.uuidString + ".jpg"
        let filePath = getImageFolderPath() + filename
        return filePath
    }
    private func getImageFolderPath() -> String {
        return "/app/images/"
    }
    private func getDomainUrl() -> String {
        return "http://192.168.2.13:8080/"
    } 
    private func fileExists(id: UUID) -> Bool {
        let fileManager = FileManager.default
        let filePath = getImageFolderPath() + id.uuidString + ".jpg"
        let result = fileManager.fileExists(atPath: filePath)
        print("Se esta verificado que exista la imagen: \(result) file: \(filePath)")
        return result
    }
    private func createFile(id: UUID, imageData: Data) throws {
        // Crear el directorio si no existe
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: getImageFolderPath(), withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error al crear el directorio de imágenes: \(error)")
            throw Abort(.badRequest, reason: "Error al crear el directorio de imágenes: \(error)")
        }
        // Escribir los datos de la imagen en el archivo
        fileManager.createFile(atPath: getPathById(id: id), contents: imageData, attributes: nil)
    }
    private func getImageUrlByHash(hash: String, req: Request) async throws -> ImageUrl? {
        return try await ImageUrl.query(on: req.db)
            .filter(\.$imageHash == hash)
            .first()
    }
    private func getImageUrlByUrl(url: String, req: Request) async throws -> ImageUrl? {
        return try await ImageUrl.query(on: req.db)
            .filter(\.$imageUrl == url)
            .first()
    }
}
