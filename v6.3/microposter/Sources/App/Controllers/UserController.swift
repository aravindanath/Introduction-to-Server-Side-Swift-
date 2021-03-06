//
//  UserController.swift
//  App
//
//  Created by Johann Kerr on 3/12/18.
//

import Foundation
import Vapor
import Fluent
import Authentication
import Crypto

final class UserController : RouteCollection {
    func boot(router: Router) throws {
        // GET /posts
        // POST /posts
        
        let usersRouter = router.grouped("users")
        usersRouter.get("/",use: index)
        usersRouter.post("/", use: create)
        usersRouter.get(User.PublicUser.parameter, use: show)
        usersRouter.get(User.PublicUser.parameter, "posts", use: showPosts)
        usersRouter.post("login", use: loginHandler)
        
        
    
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        
        let authGroup = usersRouter.grouped(basicAuthMiddleware)
        
        
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenGroup = usersRouter.grouped(tokenAuthMiddleware)
        tokenGroup.get("posts", use: handleUserPosts)
        // users/:id/posts
    }
    
    
    
    func handleUserPosts(_ req: Request) throws -> Future<[Post]> {
        let user = try req.requireAuthenticated(User.self)
        return try user.posts.query(on: req).all()
    }
    
    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token(user)
        return token.save(on: req)
    }
    
    
    func index(_ req:Request) throws -> Future<[User.PublicUser]> {
        return User.PublicUser.query(on: req).all()
    }
    
    
    func create(_ req: Request) throws -> Future<User.PublicUser> {
        /*
         { username: "johann", "password": "ilovevapor" }
         
         */
        return try req.content.decode(User.self).map(to: User.PublicUser.self) { user in
            
            let hasher = try req.make(BCryptDigest.self)
            let hashedPassword = try hasher.hash(user.password)
            user.password = hashedPassword
            user.save(on: req)
            let publicUser = User.PublicUser(user: user)
            
            return publicUser
            
            
            
        }
        
    }
    
    
    /// GET /posts/:id
    
    func show(_ req: Request) throws -> Future<User.PublicUser> {
        return try req.parameter(User.PublicUser.self)
    }
    
    
    func showPosts(_ req: Request) throws -> Future<[Post]> {
        return try req.parameter(User.self).flatMap(to: [Post].self) { user in
            return try user.posts.query(on: req).all()
            
        }
    }
    
    
    
}

