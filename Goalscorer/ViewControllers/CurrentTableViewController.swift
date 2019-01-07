//
//  CurrentTableViewController.swift
//  Goalscorer
//
//  Created by tichinose1 on 2018/12/30.
//  Copyright © 2018 example.com. All rights reserved.
//

import UIKit
import TDBadgedCell
import RealmSwift

private enum Section: Int, CaseIterable {
    case favorites
    case scorers

    var header: String {
        switch self {
        case .favorites: return "Favorites"
        case .scorers: return "Scorers"
        }
    }
}

class CurrentTableViewController: UITableViewController {

    private lazy var favorites = LocalStorage<FavoriteScorer>().findAll()
    private lazy var scorers = LocalStorage<Scorer>()
        .findAll()
        .filter("season IN {'2018', '2018–19', '2019'}")
        .sorted(by: [SortDescriptor(keyPath: "season", ascending: false),
                     SortDescriptor(keyPath: "competition.kind", ascending: true),
                     SortDescriptor(keyPath: "competition.order", ascending: true)])

    override func viewDidLoad() {
        super.viewDidLoad()

        // 通知をタップしてフォアグラウンドになった際にviewWillAppearが呼ばれないためアプリのフォアグラウンド復帰イベントに登録しておく
        NotificationCenter.default.addObserver(self, selector: #selector(onAppForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension CurrentTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)!.header
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .favorites: return favorites.count
        case .scorers: return scorers.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section(rawValue: indexPath.section)!

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "currentCell") as? TDBadgedCell else {
            fatalError()
        }
        cell.badgeColor = .red
        // セルに更新通知を表示する
        cell.badgeString = {
            switch section {
            case .favorites: return favorites[indexPath.row].updated ? "1" : ""
            case .scorers: return ""
            }
        }()

        let scorer: Scorer = {
            switch section {
            case .favorites: return favorites[indexPath.row].scorer
            case .scorers: return scorers[indexPath.row]
            }
        }()
        cell.textLabel?.text = scorer.title
        cell.imageView?.image = createImage(code: scorer.competition.association.regionCode)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension CurrentTableViewController {

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addAction = UIContextualAction(style: .normal, title: "Favorite") { _, _, completion in
            let scorer = self.scorers[indexPath.row]
            if case .none = scorer.favorite {
                // scorerにfavoriteが1件も関連づいていない場合のみ追加する
                let favorite = FavoriteScorer()
                favorite.scorer = scorer
                LocalStorage<FavoriteScorer>().add(t: favorite)
                self.tableView.reloadData()
            }
            completion(true)
        }
        let removeAction = UIContextualAction(style: .destructive, title: "Remove Favorite") { _, _, completion in
            let favorite = self.favorites[indexPath.row]
            LocalStorage<FavoriteScorer>().delete(t: favorite)
            self.tableView.reloadData()
            completion(true)
        }
        let actions: [UIContextualAction] = {
            switch Section(rawValue: indexPath.section)! {
            case .favorites: return [removeAction]
            case .scorers: return [addAction]
            }
        }()
        return UISwipeActionsConfiguration(actions: actions)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = Section(rawValue: indexPath.section)!
        // いずれのセクションからタップされたか関係なく、favoritesの最終参照時刻を更新する
        let favorite: FavoriteScorer? = {
            switch section {
            case .favorites: return favorites[indexPath.row]
            case .scorers: return scorers[indexPath.row].favorite
            }
        }()
        LocalStorage<FavoriteScorer>().update {
            favorite?.lastReadAt = Date()
        }

        let scorer: Scorer = {
            switch section {
            case .favorites: return favorites[indexPath.row].scorer
            case .scorers: return scorers[indexPath.row]
            }
        }()
        presentSafariViewController(url: scorer.url)
    }
}

// MARK: - Private functions

private extension CurrentTableViewController {

    @objc func onAppForeground() {
        tableView.reloadData()
    }
}
