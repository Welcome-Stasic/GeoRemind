import SwiftUI

struct ProfileView: View {
    let user: UserProfile
    @Environment(\.dismiss) var dismiss
    @State private var userName: String
    
    init(user: UserProfile) {
        self.user = user
        _userName = State(initialValue: user.name)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Информация") {
                    HStack {
                        Text("Имя")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("Имя", text: $userName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Email")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(user.email)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                    } label: {
                        HStack {
                            Spacer()
                            Text("Выйти из аккаунта")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    .disabled(true)
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView(user: UserProfile(id: "preview", email: "preview@example.com", name: "Тестовый пользователь"))
}
