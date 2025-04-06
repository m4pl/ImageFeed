//
//  ViewController.swift
//  ImageFeed
//
//  Created by Matvei Plokhov on 12.02.2024.
//

import UIKit

class ImagesListViewController: UIViewController, ImagesListView {
    
    @IBOutlet private var tableView: UITableView!

    private lazy var presenter = ImagesListPresenter(view: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func updateImages() {
        tableView.reloadData()
    }
}

extension ImagesListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.imagesCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }

        let viewModel = presenter.viewModel(for: indexPath.row)
        cell.configure(with: viewModel)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = presenter.viewModel(for: indexPath.row).image ?? UIImage()
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - insets.left - insets.right
        let scale = imageViewWidth / image.size.width

        return image.size.height * scale + insets.top + insets.bottom
    }
}
