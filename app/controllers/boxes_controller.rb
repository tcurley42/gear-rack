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
    if !params[box].empty?
      @user = current_user
      @box = Box.create(params[box])
      @user.boxes << @box

      redirect "/boxes/#{@box.id}"
    end
    redirect "/boxes"
  end

  # GET: /boxes/5
  get "/boxes/:id" do
    if !logged_in?
      redirect '/login'
    else
      @box = Box.find(params[id])
      erb :"/boxes/show.html"
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
    redirect "/boxes/:id"
  end

  # DELETE: /boxes/5/delete
  delete "/boxes/:id/delete" do
    redirect "/boxes"
  end
end
