class PostsController < ApplicationController


  # GET /posts
  # GET /posts.xml
  def index
    gxapi_get_variant("Untitled experiment")
    return render
  end

end
