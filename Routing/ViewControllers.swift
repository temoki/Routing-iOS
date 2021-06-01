import UIKit

let logNotificationName = Notification.Name("LOG")

class RootViewController: ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: logNotificationName, object: nil, queue: .main) { [weak self] _ in
            if let root = self {
                Self.log("root", root)
            }
        }
    }
}

class RootNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: logNotificationName, object: nil, queue: .main) { [weak self] _ in
            if let root = self {
                Self.log("root", root)
            }
        }
    }
}

class RootTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: logNotificationName, object: nil, queue: .main) { [weak self] _ in
            if let root = self {
                Self.log("root", root)
            }
        }
    }
}

class ViewController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        title = address
        navigationItem.prompt = typename
        let shape = ["spade", "heart", "club", "diamond"].randomElement()!
        tabBarItem.image = tabBarItem.image ?? UIImage(systemName: "suit.\(shape)")
    }
    
    private var typename: String { String(describing: type(of: self)) }
    private var address: String { String(describing: Unmanaged.passUnretained(self).toOpaque()) }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        view.backgroundColor = .white
        
        vstack.axis = .vertical
        vstack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vstack)
        NSLayoutConstraint.activate([
            vstack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            vstack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            vstack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            vstack.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 8),
            vstack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -8)
        ])

        let label = UILabel()
        label.text = "\(typename) <\(address)>"
        label.font = UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
        label.textAlignment = .center
        vstack.addArrangedSubview(label)
        vstack.addArrangedSubview(UIButton(primaryAction: .init(title: "Log", handler: { _ in
            NotificationCenter.default.post(name: logNotificationName, object: nil)
        })))
        vstack.addArrangedSubview(UIButton(primaryAction: .init(title: "Present", handler: { [weak self] _ in
            self?.present(ViewController(), animated: true)
        })))
        vstack.addArrangedSubview(UIButton(primaryAction: .init(title: "Present with NavigationController", handler: { [weak self] _ in
            self?.present(UINavigationController(rootViewController: ViewController()), animated: true)
        })))
        vstack.addArrangedSubview(UIButton(primaryAction: .init(title: "Present with TabBarController", handler: { [weak self] _ in
            let tabBarController = UITabBarController()
            tabBarController.viewControllers = [UINavigationController(rootViewController: ViewController()), ViewController()]
            tabBarController.selectedIndex = 0
            self?.present(tabBarController, animated: true)
        })))
        vstack.addArrangedSubview(UIButton(primaryAction: .init(title: "Add child", handler: { [weak self] _ in
            guard let self = self else { return }
            var white: CGFloat = 1
            var alpha: CGFloat = 1
            self.view.backgroundColor?.getWhite(&white, alpha: &alpha)
            
            let childViewController = ViewController()
            self.addChild(childViewController)
            self.vstack.addArrangedSubview(childViewController.view)
            childViewController.didMove(toParent: self)
            childViewController.view.backgroundColor = UIColor(white: white - 0.1, alpha: alpha)
        })))

        if navigationController != nil {
            vstack.addArrangedSubview(UIButton(primaryAction: .init(title: "Push", handler: { [weak self] _ in
                self?.navigationController?.pushViewController(ViewController(), animated: true)
            })))
            vstack.addArrangedSubview(UIButton(primaryAction: .init(title: "Present on NavigationController", handler: { [weak self] _ in
                self?.navigationController?.present(ViewController(), animated: true)
            })))
        }
        
        if tabBarController != nil {
            vstack.addArrangedSubview(UIButton(primaryAction: .init(title: "Present on TabBarController", handler: { [weak self] _ in
                self?.tabBarController?.present(ViewController(), animated: true)
            })))
        }
    }
    
    private let vstack = UIStackView()
}

extension UIViewController {
    static func log(_ name: String, _ viewController: UIViewController, _ level: Int = 0) {
        let padding = String(repeating: "  ", count: level)
        
        // Self
        print(padding, name, String(describing: viewController))
        
        // Parents
        if let parent = viewController.parent {
            print(padding + "  ", "parent", parent)
        }
        if let presentingViewController = viewController.presentingViewController {
            print(padding + "  ", "presentingViewController", presentingViewController)
        }
        if let navigationController = viewController.navigationController {
            print(padding + "  ", "navigationController", navigationController)
        }
        if let tabBarController = viewController.tabBarController {
            print(padding + "  ", "tabBarController", tabBarController)
        }

        // Childs
        if let presentedViewController = viewController.presentedViewController {
            log("presentedViewController", presentedViewController, level + 1)
        }
        if let navigationController = viewController as? UINavigationController {
            assert(viewController.children == navigationController.viewControllers)
            print(padding + "  ", "viewControllers", navigationController.viewControllers.count)
            for (index, childViewController) in navigationController.viewControllers.enumerated() {
                log("viewControllers[\(index)]", childViewController, level + 2)
            }
            if let topViewController = navigationController.topViewController {
                print(padding + "  ", "topViewController", topViewController)
            }
            if let visibleViewController = navigationController.visibleViewController {
                print(padding + "  ", "visibleViewController", visibleViewController)
            }
        } else if let tabBarController = viewController as? UITabBarController {
            assert(viewController.children == tabBarController.viewControllers)
            print(padding + "  ", "viewControllers", tabBarController.viewControllers?.count ?? 0)
            for (index, childViewController) in (tabBarController.viewControllers ?? []).enumerated() {
                log("viewControllers[\(index)]", childViewController, level + 2)
            }
            if let selectedViewController = tabBarController.selectedViewController {
                print(padding + "  ", "selectedViewController", selectedViewController)
            }
        }
        print(padding + "  ", "children", viewController.children.count)
        for (index, child) in viewController.children.enumerated() {
            log("children[\(index)]", child, level + 2)
        }
    }
}
