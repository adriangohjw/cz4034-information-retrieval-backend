class Post < ApplicationRecord

  searchkick

  def search_data
    {
      body: preprocessed_body,
      hashtags: hashtags,
      creator_score: calculate_creator_score,
      reach_score: calculate_reach_score,
      posted_at: posted_at
    }
  end

  def preprocessed_body
    Post.remove_words_from_text(text: body, words: hashtags)
  end

  # score creator based on verified status, followers, following etc.
  def calculate_creator_score
    normalized_followers_score * normalized_verified_score * normalized_following_score
  end

  # score post's impact and reach based on impressions, upvotes, reposts
  def calculate_reach_score
    normalized_impressions_score * normalized_upvotes_score * normalized_reposts_score
  end

  def normalized_followers_score(histogram_bins: Post.followers_histogram[0])
    return 0 if histogram_bins.blank?
    Post.get_bin_position(value: self.followers, bins: histogram_bins).to_f / histogram_bins.size.to_f
  end

  def normalized_following_score(histogram_bins: Post.following_histogram[0])
    return 0 if histogram_bins.blank?
    (histogram_bins.size - Post.get_bin_position(value: self.following, bins: histogram_bins)).to_f / histogram_bins.size.to_f
  end

  def normalized_verified_score
    case self.verified
    when true
      return 1.0
    when false
      return 0.5
    else
      return 0.0
    end
  end

  def normalized_impressions_score(histogram_bins: Post.impressions_histogram[0])
    return 0 if histogram_bins.blank?
    Post.get_bin_position(value: self.impressions, bins: histogram_bins).to_f / histogram_bins.size.to_f
  end

  def normalized_upvotes_score(histogram_bins: Post.upvotes_histogram[0])
    return 0 if histogram_bins.blank?
    Post.get_bin_position(value: self.upvotes, bins: histogram_bins).to_f / histogram_bins.size.to_f
  end

  def normalized_reposts_score(histogram_bins: Post.reposts_array[0])
    return 0 if histogram_bins.blank?
    Post.get_bin_position(value: self.reposts, bins: histogram_bins).to_f / histogram_bins.size.to_f
  end

  def self.followers_histogram(followers_array: Post.all.pluck(:followers), histogram_size: 100)
    followers_array.reject! { |x| x.nil? }
    (bins, freqs) = followers_array.histogram(histogram_size)
  end

  def self.following_histogram(following_array: Post.all.pluck(:following), histogram_size: 100)
    following_array.reject! { |x| x.nil? }
    (bins, freqs) = following_array.histogram(histogram_size)
  end

  def self.impressions_histogram(impressions_array: Post.all.pluck(:impressions), histogram_size: 100)
    impressions_array.reject! { |x| x.nil? }
    (bins, freqs) = impressions_array.histogram(histogram_size)
  end

  def self.upvotes_histogram(upvotes_array: Post.all.pluck(:upvotes), histogram_size: 100)
    upvotes_array.reject! { |x| x.nil? }
    (bins, freqs) = upvotes_array.histogram(histogram_size)
  end

  def self.reposts_array(reposts_array: Post.all.pluck(:reposts), histogram_size: 100)
    reposts_array.reject! { |x| x.nil? }
    (bins, freqs) = reposts_array.histogram(histogram_size)
  end

  private

  def self.remove_words_from_text(text:, words:) 
    words&.each { |word| text.slice!(word) }
    return text;
  end

  def self.get_bin_position(value:, bins:)
    return nil if value.blank?
    
    counter = 0
    bins.each do |bin|
      break if value <= bin
      counter = counter + 1
    end
    return counter
  end

end
