class PostsController < ApplicationController
  
  before_action :authenticate_user!, :except => [:index, :show]

  before_action :find_post, :only => [:show, :edit, :update, :destroy, :posts_of_this_user]

  def index
    #@public_posts = Post.where(status: 'public')
    #@private_posts = Post.where(status: 'private')
    #             .where(user_id: session[:user_id])
    #@posts = @public_posts + @private_posts
    #@posts.sort!{ |a, b| b.updated_at <=> a.updated_at }
    
    # 在 sql, 'AND' 優先於 'OR'
    @posts = Post.where("status = ? OR status = ? AND user_id = ?", 'public', 'private', session[:user_id]).order("updated_at DESC")
  end

  def show
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new post_params
    @post.user_id = (session[:user_id] || -1)

    if @post.save
      flash[:notice] = "新增文章成功"
      redirect_to posts_path #@post
    else
      flash[:alert] = "新增文章失敗"
      render :new
    end
  end

  def edit
    if @post.user_id != session[:user_id]
      flash[:alert] = "you can't edit this post"
      redirect_to @post
    end
  end

  def update
    if @post.update post_params
      flash[:notice] = "編輯文章成功"
      redirect_to @post
    else
      flash[:alert] = "編輯文章失敗"
      render :edit
    end
  end

  # 需增加是否為author的判斷
  def destroy
    PostTagship.where(:post_id => @post).delete_all
    if @post.destroy
      flash[:notice] = "刪除文章成功"
      redirect_to posts_path
    end
  end

  # update status to 'deleted', server keeps this post in case
  def fake_delete
    #@post = Post.find(params[:format])
    @post = Post.find(params[:id])
    if @post.user_id == session[:user_id]
      @post.status = "deleted"
      @post.save
      redirect_to user_posts_path(@post.user)
    else
      flash[:alert] = "you can't delete this post"
      redirect_to @post
    end
  end

  #def posts_of_this_user
    #@user = User.find(params[:user_id])
    #@user = @post.user
    #render :posts_of_this_user
  #end

  protected

  def find_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :user_id, :status, :tag_ids => [])
  end
  
end
