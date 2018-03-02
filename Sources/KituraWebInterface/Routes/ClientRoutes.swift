import Foundation
import KituraStencil
import Kitura

func initializeClientRoutes(app: App) {
    app.router.setDefault(templateEngine:
        StencilTemplateEngine())
    app.router.all(middleware: StaticFileServer())
    
    app.router.get("/") { request, response, next in
        if let database = app.database {
            Acronym.Persistence.getAll(from: database, callback: {acronyms, error in
                guard let acronyms = acronyms else {
                    response.send(error?.localizedDescription)
                    return
                }
                var contextAcronyms: [[String: Any]] = []
                for acronym in acronyms {
                    if let id = acronym.id {
                        let map = ["short": acronym.short, "long": acronym.long, "id": id]
                        contextAcronyms.append(map)
                    }
                }
                do {
                    try response.render("home", context: ["acronyms": contextAcronyms])
                } catch let error {
                    response.send(error.localizedDescription)
                }
            })
        }
    }
}
