import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState

    @State private var language: HavenUser.Language = .english
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var occupation = "N/A"
    @State private var homeStatus = "Stably Housed"
    @State private var primaryCity = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @FocusState private var focusedField: Field?

    private enum Field { case name, phone, email, city }

    // Re-render when language changes so all labels update immediately
    private var s: (L10n.Key) -> String { { L10n.t($0) } }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 10) {
                    Image("HavenLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .font(.custom("Snell Roundhand", size: 52).bold())
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, Color(red: 0.2, green: 0.5, blue: 1.0)],
                                           startPoint: .leading, endPoint: .trailing)
                        )

                    Text(s(.welcomeToHaven))
                        .font(.title2.bold())

                    Text(s(.loginSubtitle))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 44)

                VStack(spacing: 20) {

                    // — Language first so all labels update immediately —
                    sectionHeader(s(.preferredLanguage), icon: "globe")

                    VStack(alignment: .leading, spacing: 6) {
                        pickerField(label: s(.preferredLanguage), icon: "globe", selection: $language) {
                            ForEach(HavenUser.Language.allCases) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }
                    }
                    .onChange(of: language) { _, lang in
                        appState.setLanguage(lang)
                    }

                    // — About You —
                    sectionHeader(s(.aboutYou), icon: "person.fill")

                    formField(s(.fullName), icon: "person") {
                        TextField(s(.namePlaceholder), text: $name)
                            .textContentType(.name)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .phone }
                    }

                    formField(s(.phoneNumber), icon: "phone") {
                        TextField(s(.phonePlaceholder), text: $phone)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                            .focused($focusedField, equals: .phone)
                    }

                    formField(s(.emailOptional), icon: "envelope") {
                        TextField(s(.emailPlaceholder), text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .city }
                    }

                    // — Situation —
                    sectionHeader(s(.yourSituation), icon: "info.circle.fill")

                    pickerField(label: s(.occupation), icon: "briefcase", selection: $occupation) {
                        ForEach(AppState.occupationOptions, id: \.self) { Text($0) }
                    }

                    pickerField(label: s(.homeStatus), icon: "house", selection: $homeStatus) {
                        ForEach(AppState.homeStatusOptions, id: \.self) { Text($0) }
                    }

                    // — Location —
                    sectionHeader(s(.yourArea), icon: "location.fill")

                    formField(s(.cityZip), icon: "mappin") {
                        TextField(s(.cityPlaceholder), text: $primaryCity)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .city)
                            .submitLabel(.done)
                            .onSubmit { focusedField = nil }
                    }

                    Text(s(.locationHint))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal, 24)

                // Submit
                Button {
                    focusedField = nil
                    submit()
                } label: {
                    Text(s(.getStarted))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canSubmit ? Color.blue : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!canSubmit)
                .padding(.horizontal, 24)

                Text(s(.privacyNote))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer(minLength: 32)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .environment(\.layoutDirection, language.isRTL ? .rightToLeft : .leftToRight)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear { language = appState.preferredLanguage }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).foregroundColor(.blue).font(.caption.bold())
            Text(title).font(.caption.bold()).foregroundColor(.blue)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }

    @ViewBuilder
    private func formField<Content: View>(_ label: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(label, systemImage: icon).font(.caption.bold()).foregroundColor(.secondary)
            content()
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
        }
    }

    @ViewBuilder
    private func pickerField<T: Hashable, Content: View>(
        label: String, icon: String,
        selection: Binding<T>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(label, systemImage: icon).font(.caption.bold()).foregroundColor(.secondary)
            Picker(label, selection: selection) { content() }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
        }
    }

    private var canSubmit: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 &&
        phone.trimmingCharacters(in: .whitespacesAndNewlines).count >= 7 &&
        primaryCity.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    private func submit() {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = primaryCity.trimmingCharacters(in: .whitespacesAndNewlines)

        guard n.count >= 2 else { errorMessage = "Please enter your full name."; showError = true; return }
        guard p.count >= 7 else { errorMessage = "Please enter a valid phone number."; showError = true; return }
        guard c.count >= 2 else { errorMessage = "Please enter your city or ZIP code."; showError = true; return }

        showError = false
        appState.setLanguage(language)
        appState.signIn(
            name: n, phone: p,
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            occupation: occupation, homeStatus: homeStatus, primaryCity: c
        )
    }
}

#Preview {
    LoginView().environmentObject(AppState())
}
