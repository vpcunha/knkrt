//
//  AppDelegate.swift
//  knkrt
//
//  Created by Vitor Paolozzi on 06/11/18.
//  Copyright © 2018 San Blas Studio. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Definindo as cores do fundo da TabBar e das letras e ícones
        UITabBar.appearance().barTintColor = UIColor(red: 247/255, green: 206/255, blue: 91/255, alpha: 1.0)
        UITabBar.appearance().tintColor = .black
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Recarregando filmes (para o caso de usuário ter aberto app sem conexão)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "wake up"), object: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "knkrt")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

