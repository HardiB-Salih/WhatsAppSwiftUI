//
//  UserItem.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import Foundation

// MARK: - User Data Model
struct UserItem: Identifiable, Decodable, Hashable {
    let uid: String
    var username: String
    let email: String
    var bio: String? = nil
    var profileImageUrl: String? = nil
    
    var id: String {
        return uid
    }
    
    var bioUnweappede: String {
        return bio ?? "Hey there! I am using AhatsApp."
    }
    
    static let placeholder = UserItem(uid: "!", username: "HardiB", email: "Hardib@gmail.com")
}

// MARK: - Initialization from Dictionary
extension UserItem {
    init(dictionary: [String: Any]) {
        self.uid = dictionary[.uid] as? String ?? ""
        self.username = dictionary[.username] as? String ?? ""
        self.email = dictionary[.email] as? String ?? ""
        self.bio = dictionary[.bio] as? String? ?? nil
        self.profileImageUrl = dictionary[.profileImageUrl] as? String? ?? nil
    }
}

// MARK: - String Constants
extension String {
    static let uid = "uid"
    static let username = "username"
    static let email = "email"
    static let bio = "bio"
    static let profileImageUrl = "profileImageUrl"
}


//MARK: - Test
extension UserItem {
    /// How to add test data to a firebase call it in a view model.
//    UserItem.placeholders.forEach { user in
//        Task {
//            try await AuthManager.shared.createAccount(for:user.username , email:user.email , password: "123456")
//        }
//    }
    
    // Create a list of 20 users
    static let placeholders: [UserItem] = [
        UserItem(uid: "uid1", username: "johnsmith", email: "john.smith@example.com", bio: "Loves hiking and outdoor adventures."),
        UserItem(uid: "uid2", username: "janedoe", email: "jane.doe@example.com", bio: "Enjoys painting and reading."),
        UserItem(uid: "uid3", username: "mikejohnson", email: "mike.johnson@example.com", bio: "Avid cyclist and tech enthusiast."),
        UserItem(uid: "uid4", username: "sarawilliams", email: "sara.williams@example.com", bio: "Coffee lover and yoga practitioner."),
        UserItem(uid: "uid5", username: "jamesbrown", email: "james.brown@example.com", bio: "Passionate about music and cooking."),
        UserItem(uid: "uid6", username: "emilyclark", email: "emily.clark@example.com", bio: "Traveler and photography buff."),
        UserItem(uid: "uid7", username: "michaelmiller", email: "michael.miller@example.com", bio: "Gamer and software developer."),
        UserItem(uid: "uid8", username: "lisadavis", email: "lisa.davis@example.com", bio: "Fitness enthusiast and baker."),
        UserItem(uid: "uid9", username: "robertmoore", email: "robert.moore@example.com", bio: "Historian and book collector."),
        UserItem(uid: "uid10", username: "marywilson", email: "mary.wilson@example.com", bio: "Gardener and animal lover."),
        UserItem(uid: "uid11", username: "davidwhite", email: "david.white@example.com", bio: "Tech blogger and podcaster."),
        UserItem(uid: "uid12", username: "laurajones", email: "laura.jones@example.com", bio: "Dancer and fashion enthusiast."),
        UserItem(uid: "uid13", username: "peterthomas", email: "peter.thomas@example.com", bio: "Film buff and critic."),
        UserItem(uid: "uid14", username: "kellymartin", email: "kelly.martin@example.com", bio: "Nutritionist and marathon runner."),
        UserItem(uid: "uid15", username: "kevinlee", email: "kevin.lee@example.com", bio: "Guitarist and car enthusiast."),
        UserItem(uid: "uid16", username: "amandaallen", email: "amanda.allen@example.com", bio: "Chef and food blogger."),
        UserItem(uid: "uid17", username: "chrisrobinson", email: "chris.robinson@example.com", bio: "Artist and skateboarder."),
        UserItem(uid: "uid18", username: "patriciawalker", email: "patricia.walker@example.com", bio: "Teacher and DIYer."),
        UserItem(uid: "uid19", username: "brianharris", email: "brian.harris@example.com", bio: "Gamer and fantasy writer."),
        UserItem(uid: "uid20", username: "angelaturner", email: "angela.turner@example.com", bio: "Environmental activist and blogger."),
        UserItem(uid: "uid21", username: "georgehill", email: "george.hill@example.com", bio: "Soccer player and coach."),
        UserItem(uid: "uid22", username: "dorothygreen", email: "dorothy.green@example.com", bio: "Bird watcher and botanist."),
        UserItem(uid: "uid23", username: "danielnelson", email: "daniel.nelson@example.com", bio: "Photographer and world traveler."),
        UserItem(uid: "uid24", username: "ashleycarter", email: "ashley.carter@example.com", bio: "Fashion designer and blogger."),
        UserItem(uid: "uid25", username: "stevenwright", email: "steven.wright@example.com", bio: "Writer and historian."),
        UserItem(uid: "uid26", username: "katherinebaker", email: "katherine.baker@example.com", bio: "Chef and restaurant critic."),
        UserItem(uid: "uid27", username: "ericscott", email: "eric.scott@example.com", bio: "Surfer and travel enthusiast."),
        UserItem(uid: "uid28", username: "heathermartinez", email: "heather.martinez@example.com", bio: "Poet and librarian."),
        UserItem(uid: "uid29", username: "adammorgan", email: "adam.morgan@example.com", bio: "Fitness coach and entrepreneur."),
        UserItem(uid: "uid30", username: "oliviaadams", email: "olivia.adams@example.com", bio: "Vegan and fitness trainer."),
        UserItem(uid: "uid31", username: "jasonward", email: "jason.ward@example.com", bio: "Tech geek and car lover."),
        UserItem(uid: "uid32", username: "meganrodriguez", email: "megan.rodriguez@example.com", bio: "Writer and podcast host."),
        UserItem(uid: "uid33", username: "ryanbrooks", email: "ryan.brooks@example.com", bio: "Outdoor adventurer and photographer."),
        UserItem(uid: "uid34", username: "stephaniemorris", email: "stephanie.morris@example.com", bio: "Gardener and DIY enthusiast."),
        UserItem(uid: "uid35", username: "nicholascook", email: "nicholas.cook@example.com", bio: "Musician and sound engineer."),
        UserItem(uid: "uid36", username: "rebeccajames", email: "rebecca.james@example.com", bio: "Teacher and cat lover."),
        UserItem(uid: "uid37", username: "jacobphillips", email: "jacob.phillips@example.com", bio: "Tech innovator and investor."),
        UserItem(uid: "uid38", username: "courtneykelly", email: "courtney.kelly@example.com", bio: "Yoga instructor and nutritionist."),
        UserItem(uid: "uid39", username: "lukegarcia", email: "luke.garcia@example.com", bio: "Photographer and travel blogger."),
        UserItem(uid: "uid40", username: "dianarogers", email: "diana.rogers@example.com", bio: "Dancer and choreographer."),
        UserItem(uid: "uid41", username: "jeffreycampbell", email: "jeffrey.campbell@example.com", bio: "Tech enthusiast and gamer."),
        UserItem(uid: "uid42", username: "victoriaevans", email: "victoria.evans@example.com", bio: "Fashionista and blogger."),
        UserItem(uid: "uid43", username: "austinmitchell", email: "austin.mitchell@example.com", bio: "Hiker and wildlife photographer."),
        UserItem(uid: "uid44", username: "rachelparker", email: "rachel.parker@example.com", bio: "Artist and gallery owner."),
        UserItem(uid: "uid45", username: "brandonlee", email: "brandon.lee@example.com", bio: "Entrepreneur and foodie."),
        UserItem(uid: "uid46", username: "melissaross", email: "melissa.ross@example.com", bio: "Fitness guru and health coach."),
        UserItem(uid: "uid47", username: "brendagonzalez", email: "brenda.gonzalez@example.com", bio: "Painter and museum curator."),
        UserItem(uid: "uid48", username: "gabrielcoleman", email: "gabriel.coleman@example.com", bio: "Writer and film director."),
        UserItem(uid: "uid49", username: "samanthawood", email: "samantha.wood@example.com", bio: "Gardener and floral designer."),
        UserItem(uid: "uid50", username: "benjaminstewart", email: "benjamin.stewart@example.com", bio: "Podcaster and tech reviewer.")
    ]
}
