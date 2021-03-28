class SearchController < ApplicationController

  def index
    # to be replaced
    @posts = Post.first(5)
  end

end
