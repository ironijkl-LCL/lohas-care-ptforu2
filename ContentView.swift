import SwiftUI
import Combine

public struct ContentView: View {
    // MARK: - 無障礙字體縮放與高對比狀態
    @AppStorage("fontScale") private var fontScale: Double = 1.0
    @AppStorage("isHighContrast") private var isHighContrast: Bool = true
    
    // MARK: - FuryRevive 核心資產：Revive 幣 (回血幣)
    @AppStorage("reviveCoins") private var reviveCoins: Int = 3200
    
    // MARK: - 展開發洩專區狀態
    @State private var showForgeZones: Bool = false
    
    // MARK: - 今日排毒鍛造清單狀態 (原有全部保留 + 新增排序)
    @State private var dailyVentStageDone: Bool = false     // 💳 新增：情境排序發洩
    @State private var dailyMtrDone: Bool = false           // 🚇 原有：地鐵逼爆推掌
    @State private var dailySubdividedDone: Bool = false    // 🏠 原有：迷你劏房怒踩 (完整保留)
    @State private var dailyVoiceShoutDone: Bool = false    // 🌋 原有：怨氣咆哮
    @State private var dailyPurgeBlowDone: Bool = false     // 💨 原有：怨念吹散
    @State private var dailySlippersDone: Bool = false      // 🩴 原有：口肌表情拉筋
    
    // MARK: - 緊急洩壓 / 心情急救彈窗
    @State private var showEmergencyCalmAlert: Bool = false
    @State private var navigateToIronLadyFromAlert: Bool = false
    @State private var currentTimeString: String = ""
    
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                // 背景配色：熔爐碳黑底色，突顯高對比金屬感
                (isHighContrast ? Color.black : Color(red: 0.08, green: 0.09, blue: 0.11))
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 1. 頂部資訊與金屬品牌看板
                        headerSection
                        
                        // 2. 今日怨力排毒鍛造清單 (含新增排序與保留劏房)
                        dailyPlanSection
                        
                        // 3. 核心鍛造按鈕 (保留全部四大功能 + 獨立新增 10 大目錄排序專區)
                        coreButtonsSection
                        
                        // 4. 香港限定發洩專區（展開區）
                        if showForgeZones {
                            forgeZonesSection
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                updateTime()
            }
            .onReceive(timer) { _ in
                updateTime()
            }
            .alert("🔥 即刻深呼吸 · 心理急救", isPresented: $showEmergencyCalmAlert) {
                Button("💥 入去搵鐵娘子痛快鬧", role: .destructive) {
                    navigateToIronLadyFromAlert = true
                }
                Button("慢慢深呼吸，我頂得住", role: .cancel) {}
            } message: {
                Text("咪畀千斤怨氣壓垮！香港人咁堅，慢慢呼氣，卸低包袱再戰多幾年。")
            }
            // 支援從急救彈窗直接導向鐵娘子熔爐
            .navigationDestination(isPresented: $navigateToIronLadyFromAlert) {
                VoicePracticeView()
            }
        }
    }

    // MARK: - 1. 頂部資訊與無障礙操作列
    private var headerSection: some View {
        VStack(spacing: 12) {
            // 時鐘大字
            Text(currentTimeString)
                .font(.system(size: 40 * fontScale, weight: .heavy, design: .rounded))
                .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.1)) // 熔爐亮橙
            
            // FuryRevive 品牌雙層標題排版
            VStack(spacing: 5) {
                Text("FuryRevive")
                    .font(.system(size: 26 * fontScale, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                
                Text("怨力鍛造回收空間 · 卸低怨氣 滿血復甦")
                    .font(.system(size: 15 * fontScale, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.9)) // 淬火冷藍
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            
            // 頂部功能膠囊列：急救、回血幣、無障礙字體
            HStack(spacing: 8) {
                Button(action: { showEmergencyCalmAlert = true }) {
                    Text("🚨 洩壓急救")
                        .font(.system(size: 14 * fontScale, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .cornerRadius(18)
                }
                
                // 顯示目前 Revive 幣
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(reviveCoins) 幣")
                        .font(.system(size: 14 * fontScale, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(white: 0.2))
                .cornerRadius(18)
                
                Spacer()
                
                // 無障礙 A+ / A- / 對比度切換
                HStack(spacing: 6) {
                    Button(action: { fontScale = min(1.35, fontScale + 0.1) }) {
                        Text("A+")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                    
                    Button(action: { fontScale = max(0.9, fontScale - 0.1) }) {
                        Text("A-")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                    
                    Button(action: { isHighContrast.toggle() }) {
                        Image(systemName: isHighContrast ? "circle.lefthalf.filled.inverse" : "circle.lefthalf.filled")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(7)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color(white: 0.14))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1.5)
        )
        .cornerRadius(20)
    }

    // MARK: - 2. 今日怨力排毒鍛造清單 (保留劏房 + 增加情境排序)
    private var dailyPlanSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("🔥 今日抗逆鍛造清單 (每日回血)")
                    .font(.system(size: 17 * fontScale, weight: .heavy))
                    .foregroundColor(.white)
                Spacer()
                Text("賺取回血幣")
                    .font(.system(size: 12 * fontScale, weight: .semibold))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 8) {
                // 1. [新增] 港式 10 大情境排序發洩目錄
                dailyCheckRow(title: "💳 怨力情境排序目錄 (自訂火滾榜)", isDone: $dailyVentStageDone) {
                    VentCategoryListView()
                }

                // 2. [保留] 地鐵逼爆推掌
                dailyCheckRow(title: "🚇 地鐵逼爆推掌 10 次 (霸氣回懟)", isDone: $dailyMtrDone) {
                    ScenePracticeView()
                }
                
                // 3. [原封不動保留] 劏房模型踏步跺腳
                dailyCheckRow(title: "🏠 劏房模型踏步跺腳 20 步 (識破怨念)", isDone: $dailySubdividedDone) {
                    FuryNamingPracticeView()
                }
                
                // 4. [保留] 怨氣咆哮鍛造（對接 Roar 模式）
                dailyCheckRow(title: "🌋 怨氣咆哮 10 次 (大聲怒吼鍛造)", isDone: $dailyVoiceShoutDone) {
                    FuryVoiceBlowPracticeView(mode: .roar)
                }
                
                // 5. [保留] 怨念深層吹散（對接 Purge 模式）
                dailyCheckRow(title: "💨 怨念吹散 10 次 (深呼吸排毒吐納)", isDone: $dailyPurgeBlowDone) {
                    FuryVoiceBlowPracticeView(mode: .purge)
                }
                
                // 6. [保留] 面部口肌拉筋
                dailyCheckRow(title: "🩴 港式表情拉筋 10 次 (面部鍛造)", isDone: $dailySlippersDone) {
                    MouthTrainingView()
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color(red: 0.25, green: 0.12, blue: 0.05), Color(red: 0.15, green: 0.05, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange.opacity(0.35), lineWidth: 1.5)
        )
        .cornerRadius(20)
    }

    private func dailyCheckRow<Destination: View>(title: String, isDone: Binding<Bool>, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 10) {
                Image(systemName: isDone.wrappedValue ? "checkmark.seal.fill" : "circle.dashed")
                    .foregroundColor(isDone.wrappedValue ? .orange : .gray)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.system(size: 15 * fontScale, weight: .medium))
                    .foregroundColor(isDone.wrappedValue ? .gray : .white)
                    .strikethrough(isDone.wrappedValue)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - 3. 核心四大鍛造按鈕 (保留原本全部四大功能 + 獨立新增 10 大目錄排序專區)
    private var coreButtonsSection: some View {
        VStack(spacing: 12) {
            // [新增] 港式 10 大情境排序發洩目錄入口
            NavigationLink(destination: VentCategoryListView()) {
                bigActionButtonContent(
                    icon: "sparkles.rectangle.stack.fill",
                    title: "🎭 港式情境排序發洩區",
                    subtitle: "10 大怨念破場目錄 · 怒者自訂火滾榜排序",
                    bgColor: Color(red: 0.82, green: 0.28, blue: 0.12) // 熔爐火橙紅
                )
            }

            // 1. [原有保留] 體感排毒鍛造 -> 對接 AR 口肌鏡頭鍛造
            NavigationLink(destination: MouthTrainingView()) {
                bigActionButtonContent(
                    icon: "flame.circle.fill",
                    title: "💥 體感排毒鍛造",
                    subtitle: "AR 鏡頭動作追蹤 · 面肌抗逆重鑄 · 卸低壓抑",
                    bgColor: Color(red: 0.85, green: 0.32, blue: 0.1) // 熔爐火橙
                )
            }
            
            // 2. [原有保留] 香港限定發洩場（展開 / 收起）
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    showForgeZones.toggle()
                }
            }) {
                bigActionButtonContent(
                    icon: showForgeZones ? "chevron.up.circle.fill" : "hammer.circle.fill",
                    title: showForgeZones ? "⬆️ 收起發洩專區" : "⚒️ 香港限定發洩場",
                    subtitle: "地鐵夾門 · 劏房怒踩 · 怨氣咆哮 · 怨念吹散",
                    bgColor: Color(red: 0.35, green: 0.2, blue: 0.6) // 賽博深紫
                )
            }
            
            // 3. [原有保留] Revive 幣回血中心
            NavigationLink(destination: ProgressReportView()) {
                bigActionButtonContent(
                    icon: "cup.and.saucer.fill",
                    title: "🪙 Revive 幣回血中心",
                    subtitle: "查看抗逆戰報 · 累積回血幣換咖啡與早餐券",
                    bgColor: Color(red: 0.12, green: 0.65, blue: 0.45) // 淬火翡翠綠
                )
            }
            
            // 4. [原有保留] 鐵娘子 AI 鍛造師
            NavigationLink(destination: VoicePracticeView()) {
                bigActionButtonContent(
                    icon: "waveform.badge.microphone",
                    title: "💬 鐵娘子 AI 鍛造師",
                    subtitle: "深水埗茶記老闆娘 · 陪你痛快痛罵 · 滿血再戰",
                    bgColor: Color(red: 0.15, green: 0.45, blue: 0.85) // 科技冷淬藍
                )
            }
        }
    }

    // MARK: - 4. 香港限定發洩專區（展開卡片：劏房與原有項目均在，額外增加 10 大目錄排序卡片）
    private var forgeZonesSection: some View {
        VStack(spacing: 10) {
            // [新增] 10 大目錄情境排序卡片
            NavigationLink(destination: VentCategoryListView()) {
                subExerciseCard(
                    title: "💳 怨力情境排序目錄 (10 大主題)",
                    desc: "自訂火滾順序：觸發 ➡️ 轉念回收 ➡️ 痛快宣洩！",
                    color: Color(red: 0.72, green: 0.22, blue: 0.18)
                )
            }

            // 1. [保留] 怨氣咆哮鍛造區
            NavigationLink(destination: FuryVoiceBlowPracticeView(mode: .roar)) {
                subExerciseCard(
                    title: "🌋 怨氣咆哮鍛造區",
                    desc: "聲控大聲怒吼：大嗌「呀～！」轉化怒火能量！",
                    color: Color(red: 0.8, green: 0.2, blue: 0.15)
                )
            }
            
            // 2. [保留] 怨念深層吹散區
            NavigationLink(destination: FuryVoiceBlowPracticeView(mode: .purge)) {
                subExerciseCard(
                    title: "💨 怨念深層吹散區",
                    desc: "吐納排毒均勻吹氣：吹走積壓鬱悶，深層清毒！",
                    color: Color(red: 0.15, green: 0.55, blue: 0.75)
                )
            }
            
            // 3. [保留] 地鐵憤怒夾門區
            NavigationLink(destination: ScenePracticeView()) {
                subExerciseCard(
                    title: "🚇 地鐵憤怒夾門區",
                    desc: "霸氣報路自保：『閃啦！逼到上嚟啦！』",
                    color: Color(red: 0.75, green: 0.25, blue: 0.25)
                )
            }
            
            // 4. [原封不動保留] 迷你劏房怒踩區
            NavigationLink(destination: FuryNamingPracticeView()) {
                subExerciseCard(
                    title: "📦 迷你劏房怒踩區",
                    desc: "雙指縮放識破物件：『7000 蚊住個籠咁！！』",
                    color: Color(red: 0.65, green: 0.4, blue: 0.15)
                )
            }
            
            // 5. [保留] 自由行插隊復仇區
            NavigationLink(destination: ScenePracticeView()) {
                subExerciseCard(
                    title: "🚩 自由行插隊復仇區",
                    desc: "排隊霸氣回懟：『唔好插隊好喎！老友請排隊！』",
                    color: Color(red: 0.2, green: 0.55, blue: 0.65)
                )
            }
            
            // 6. [保留] 廣東話音波排毒區
            NavigationLink(destination: TonePracticeView()) {
                subExerciseCard(
                    title: "🩴 廣東話音波排毒區",
                    desc: "六度音階咆哮：『成日丟嘢落嚟呀！大聲嗌出嚟！』",
                    color: Color(red: 0.5, green: 0.2, blue: 0.5)
                )
            }
        }
        .padding(.top, 4)
    }

    // MARK: - 輔助卡片組件
    private func bigActionButtonContent(icon: String, title: String, subtitle: String, bgColor: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 34))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20 * fontScale, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 13 * fontScale, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(bgColor)
        .cornerRadius(20)
        .shadow(color: bgColor.opacity(0.35), radius: 8, x: 0, y: 4)
    }

    private func subExerciseCard(title: String, desc: String, color: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16 * fontScale, weight: .bold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 12 * fontScale))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "arrow.right.circle.fill")
                .font(.title3)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(color)
        .cornerRadius(16)
    }

    // MARK: - 邏輯處理
    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        currentTimeString = formatter.string(from: Date())
    }
}

#Preview {
    ContentView()
}
