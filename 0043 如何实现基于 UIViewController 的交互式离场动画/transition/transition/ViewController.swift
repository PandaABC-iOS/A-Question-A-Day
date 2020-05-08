//
//  ViewController.swift
//  transition
//
//  Created by songzhou on 2020/4/20.
//  Copyright © 2020 songzhou. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(ImageCell.self, forCellReuseIdentifier: "imageVertical")
    }


    let dataSource = ["imageVertical", "imageVertical", "imageVertical"]
    var transition: CardTransition?
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataSource[indexPath.row]
        
        switch data {
        case "imageVertical":
            let cell = tableView.dequeueReusableCell(withIdentifier: data) as! ImageCell
            switch indexPath.row {
            case 0:
                cell.setImage(image: UIImage(named: "black-steel-lamp-post")!)
            case 1:
                cell.setImage(image: UIImage(named: "concrete-road-during-dawn")!)
            case 2:
                cell.setImage(image: UIImage(named: "stranger-things-2-sign-in-city-at-night-1089194")!)
            default:
                break
            }

            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataSource[indexPath.row]

        switch data {
        case "imageVertical":
            let cell = tableView.cellForRow(at: indexPath) as! ImageCell
            let vc = ImageDetailViewController()
            vc.setImage(image: cell.bgImageView.image!)
            
            self.navigationController?.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

class ImageCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        bgImageView = UIImageView()

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        contentView.addSubview(bgImageView)
        bgImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            bgImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            bgImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 32),
            bgImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -32),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(image: UIImage) {
        bgImageView.image = image
        
        ratioConstraint?.isActive = false
        ratioConstraint = bgImageView.heightAnchor.constraint(equalTo: bgImageView.widthAnchor, multiplier: image.size.height/image.size.width, constant: 0)
        ratioConstraint?.isActive = true
    }

    let bgImageView: UIImageView
    var ratioConstraint: NSLayoutConstraint?
}

extension ViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        switch operation {
        case .push:
            let detailVC = toVC as? ImageDetailViewController

            let cell = tableView.cellForRow(at: tableView!.indexPathForSelectedRow!) as! ImageCell
            
            let fromFrame = cell.bgImageView.superview!.convert(cell.bgImageView.frame, to: nil)

            detailVC?.fromImageViewFrame = fromFrame
            
            let insetTop = view.safeAreaInsets.top
            
            transition = CardTransition(params: CardTransition.Params(fromCardFrame: fromFrame,
                                                                      toCardFrame: CGRect(x: 0,
                                                                                          y: insetTop,
                                                                                          width: view.bounds.width,
                                                                                          height: view.bounds.width*fromFrame.height/fromFrame.width),
                                                                      fromCell: cell))
            
            return transition?.pushAnimator
        case .pop:
            let detailVC = fromVC as? ImageDetailViewController
            
            let pop = transition?.popAnimator
            
            if let frame = detailVC?.popInteractor?.dragFinalFrame {
                pop?.fromCardFrame = frame
            }
            
            return pop
        default:
            return nil
        }
    }
}
