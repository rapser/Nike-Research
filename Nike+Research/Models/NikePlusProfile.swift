struct NikePlusActivity {
    let title: String
    let value: String
    let unit: String
}

struct NikePlusProfile {
    let name: String
    let memberSince: String
    let avatarImageName: String
    let activities: [NikePlusActivity]

    static func dummy() -> NikePlusProfile {
        NikePlusProfile(
            name: "Jordan Runner",
            memberSince: "Member since 2019",
            avatarImageName: "s1",
            activities: [
                NikePlusActivity(title: "RUNS THIS MONTH", value: "12", unit: "runs"),
                NikePlusActivity(title: "DISTANCE", value: "87.4", unit: "km"),
                NikePlusActivity(title: "BEST PACE", value: "5:32", unit: "min/km"),
                NikePlusActivity(title: "CALORIES", value: "4,200", unit: "kcal")
            ]
        )
    }
}
