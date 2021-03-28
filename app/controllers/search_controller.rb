class SearchController < ApplicationController

  def index
    @posts = Post.get_search_results(search_term: params[:search_term])
  end

end
