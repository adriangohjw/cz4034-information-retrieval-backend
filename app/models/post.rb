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
  end

  # score post's impact and reach based on impressions, upvotes, reposts
  def calculate_reach_score
  end

  private

  def self.remove_words_from_text(text:, words:) 
    words&.each { |word| text.slice!(word) }
    return text;
  end

end
