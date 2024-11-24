import Foundation
import SwiftUI

extension View {
    public func navigationBarColor(backgroundColor: UIColor, textColor: UIColor) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, textColor: textColor))
    }
}

struct NavigationBarModifier: ViewModifier {
    var backgroundColor: UIColor
    var textColor: UIColor
    
    init(backgroundColor: UIColor, textColor: UIColor) {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = backgroundColor
        coloredAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .bold), .foregroundColor: textColor]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: textColor]

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }

    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    Color(backgroundColor)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

extension UIColor {
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
}

struct ConditionalSwipeActionsModifier: ViewModifier {
    var swipeActions: () -> AnyView
    var longPressActions: (() -> Void)?

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.swipeActions {
                swipeActions()
            }
        } else {
            content
                .onLongPressGesture {
                    longPressActions?()
                }
        }
    }
}

extension View {
    // 条件执行 swipeActions 的方法
    func conditionalSwipeActions(
        @ViewBuilder swipeActions: @escaping () -> some View,
        longPressActions: (() -> Void)? = nil
    ) -> some View {
        self.modifier(ConditionalSwipeActionsModifier(
            swipeActions: { AnyView(swipeActions()) },
            longPressActions: longPressActions
        ))
    }
}
