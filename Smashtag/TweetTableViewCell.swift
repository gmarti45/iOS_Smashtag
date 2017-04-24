//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Gloria Martinez on 4/24/17.
//  Copyright © 2017 Gloria Martinez. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    var tweet: Twitter.Tweet? { didSet { updateUI() } }
    
    private func updateUI() {
        tweetTextLabel?.text = tweet?.text
        tweetUserLabel?.text = tweet?.user.description
        
        if let tweet = self.tweet{
            tweetTextLabel?.attributedText = highlightMentions(tweet: tweet)
        }
        
        
        if let profileImageURL = tweet?.user.profileImageURL {
            // MARK: Fetch data off the main queue
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let imageData = try? Data(contentsOf: profileImageURL) {
                    // MARK: UI -> Back to main queue
                    DispatchQueue.main.async {
                        self?.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            tweetProfileImageView?.image = nil
        }
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
        
    }
    
    private func highlightMentions(tweet: Tweet) -> NSMutableAttributedString {
        let text = tweet.text
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.setMensionsColor(mensions: tweet.hashtags, color: UIColor.magenta)
        attributedText.setMensionsColor(mensions: tweet.urls, color: UIColor.blue)
        attributedText.setMensionsColor(mensions: tweet.userMentions, color: UIColor.green)
        return attributedText
    }
    
}

private extension NSMutableAttributedString {
    func setMensionsColor(mensions: [Mention], color: UIColor) {
        for mension in mensions {
            addAttribute(NSForegroundColorAttributeName, value: color, range: mension.nsrange)
        }
    }
}
