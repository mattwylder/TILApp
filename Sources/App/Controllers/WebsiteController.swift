//
//  WebsiteController.swift
//  
//
//  Created by Matthew Wylder on 4/22/22.
//

import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: indexHandler)
        routes.get("acronyms", ":acronymID", use: acronymHandler)
        routes.get("users", ":userID", use: userHandler)
        routes.get("users", use: allUsersHandler)
        routes.get("categories", use: allCategoriesHandler)
        routes.get("categories", ":categoryID", use: categoryHandler)
    }
    
    func indexHandler(_ req: Request) async throws -> View {
        let acronyms = try await Acronym.query(on: req.db).all()
        let context = IndexContext(title: "Home Page", acronyms: acronyms)
        return try await req.view.render("index", context)
    }
    
    func acronymHandler(_ req: Request) async throws -> View {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound)
        }

        let user = try await acronym.$user.get(on: req.db)
        let context = AcronymContext(title: acronym.short, acronym: acronym, user: user)
        return try await req.view.render("acronym", context)
    }
    
    func userHandler(_ req: Request) async throws -> View {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let acronyms = try await user.$acronyms.get(on: req.db)
        let context = UserContext(title: user.name, user: user, acronyms: acronyms)
        return try await req.view.render("user", context)
    }
    
    func allUsersHandler(_ req: Request) async throws -> View {
        let users = try await User.query(on: req.db).all()
        let context = AllUsersContext(title: "All Users", users: users)
        return try await req.view.render("allUsers", context)
    }
    
    func allCategoriesHandler(_ req: Request) async throws -> View {
        let categories = try await Category.query(on: req.db).all()
        let context = AllCategoriesContext(categories: categories)
        return try await req.view.render("allCategories", context)
    }
    
    func categoryHandler(_ req: Request) async throws -> View {
        guard let category = try await Category.find(req.parameters.get("categoryID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let acronyms = try await category.$acronyms.get(on: req.db)
        let context = CategoryContext(title: category.name, category: category, acronyms: acronyms)
        return try await req.view.render("category", context)
        
    }
}

struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]
}

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: User
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let acronyms: [Acronym]
}

struct AllUsersContext: Encodable {
    let title: String
    let users: [User]
}

struct AllCategoriesContext: Encodable {
    let title = "All Categories"
    let categories: [Category]
}

struct CategoryContext: Encodable {
    let title: String
    let category: Category
    let acronyms: [Acronym]
}
