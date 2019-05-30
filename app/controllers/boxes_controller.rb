class BoxesController < ApplicationController

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
      erb :"/boxes/edit.html"
    end
  end

  # PATCH: /boxes/5
  patch "/boxes/:id" do
    if !logged_in?
      redirect '/login'
    else
      if !params[:name].empty?
        @box = Box.find(params[:id])
        @box.update(name: params[:name])
      end
    redirect "/boxes/#{params[:id]}"
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
        redirect "/boxes/#{params[:id]}"
      end
    end
  end
end
