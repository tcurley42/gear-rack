class BoxesController < ApplicationController
  register Sinatra::Flash

  # GET: /boxes
  get "/boxes" do
    if !logged_in?
      redirect '/login'
    else
      erb :"/boxes/index.html"
    end
  end

  # GET: /boxes/new
  get "/boxes/new" do
    if logged_in?
      erb :"/boxes/new.html"
    else
      redirect '/login'
    end
  end

  # POST: /boxes
  post "/boxes" do
    if !params[:box].empty? && !params[:box][:name].empty?
      @user = current_user
      @box = Box.create(params[:box])
      @user.boxes << @box

      redirect "/boxes/#{@box.id}"
    else
      redirect "/boxes/new"
    end
  end

  # GET: /boxes/5
  get "/boxes/:id" do
    if !logged_in?
      redirect '/login'
    else
      @box = Box.find_by(id: params[:id])
      if !@box.nil?
        erb :"/boxes/show.html"
      else
        redirect "/boxes"
      end
    end
  end

  # GET: /boxes/5/edit
  get "/boxes/:id/edit" do
    if !logged_in?
      redirect '/login'
    else
      @box = Box.find_by(id: params[:id])
      @user = current_user
      if !@box.nil? && @user.id == @box.user.id
        erb :"/boxes/edit.html"
      else
        flash[:message] = "You don't have permissions to edit someone else's box!"
        redirect "/boxes"
      end
    end
  end

  # PATCH: /boxes/5
  patch "/boxes/:id" do
    if !logged_in?
      redirect '/login'
    else
      if !params[:name].empty?
        @box = Box.find_by(id: params[:id])
        if !@box.nil?
          @box.update(name: params[:name])
          redirect "/boxes/#{@box.id}"
        else 
          redirect "/boxes"
        end
      else
        redirect "/boxes/#{params[:id]}/edit"
      end
    end
  end

  # DELETE: /boxes/5/delete
  delete "/boxes/:id/delete" do
    if !logged_in?
      redirect '/login'
    else
      user = current_user
      box = Box.find(params[:id])
      if box.user_id == user.id
        box.destroy
        redirect "/boxes"
      else
        flash[:message] = "You don't have permission to edit someone else's item!"
        redirect "/boxes"
      end
    end
  end
end
