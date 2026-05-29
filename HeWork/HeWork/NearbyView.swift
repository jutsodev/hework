import SwiftUI

struct NearbyView: View {
    @State private var isScanning = true
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                VStack(spacing: 24) {
                    ZStack {
                        ForEach(1...3, id: \.self) { i in
                            Circle().stroke(Color.appAccent.opacity(0.15), lineWidth: 1)
                                .frame(width: CGFloat(i) * 100, height: CGFloat(i) * 100)
                        }
                        Circle()
                            .fill(RadialGradient(colors: [.appAccent, .appAccent.opacity(0.3)], center: .center, startRadius: 0, endRadius: 20))
                            .frame(width: 40, height: 40)
                            .overlay(Image(systemName: "antenna.radiowaves.left.and.right").font(.system(size: 16)).foregroundColor(.white))
                        if isScanning {
                            Circle().stroke(Color.appAccent.opacity(0.4), lineWidth: 2).frame(width: 40, height: 40)
                                .scaleEffect(isScanning ? 4 : 1).opacity(isScanning ? 0 : 0.6)
                                .animation(.easeOut(duration: 2).repeatForever(autoreverses: false), value: isScanning)
                        }
                    }.frame(height: 320)

                    VStack(spacing: 8) {
                        Text("Поиск nearby").font(.title2.bold()).foregroundColor(.white)
                        Text("Поиск пользователей поблизости\nс помощью Bluetooth Mesh")
                            .font(.subheadline).foregroundColor(.appTextSecondary).multilineTextAlignment(.center)
                    }

                    VStack(spacing: 12) {
                        NearbyUserCard(name: "Алексей", distance: "~12м", handle: "@alexey")
                        NearbyUserCard(name: "Мария", distance: "~25м", handle: "@maria")
                        NearbyUserCard(name: "Дмитрий", distance: "~48м", handle: "@dmitry")
                    }.padding(.horizontal, 20)
                    Spacer()
                }.padding(.top, 20)
            }
            .navigationTitle("Рядом").navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
        }
    }
}

struct NearbyUserCard: View {
    let name: String, distance: String, handle: String
    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(LinearGradient(colors: [.appPurple, .appPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 44, height: 44)
                .overlay(Text(String(name.prefix(1))).font(.system(size: 18, weight: .bold)).foregroundColor(.white))
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                Text(handle).font(.caption).foregroundColor(.appTextSecondary)
            }
            Spacer()
            Text(distance).font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(.appAccent)
                .padding(.horizontal, 10).padding(.vertical, 4).background(Color.appAccent.opacity(0.15)).cornerRadius(8)
        }
        .padding(14).background(Color.appCard).cornerRadius(14)
    }
}
