class ItemsController < ApplicationController

  # GET: /items
  get "/items" do
    if !logged_in?
      redirect '/login'
    else
      erb :"/items/index.html"
    end
  end

  # GET: /items/new
  get "/boxes/:box_id/items/new" do
    if logged_in?
      erb :"/items/new.html"
    else
      redirect '/login'
    end
  end

  # POST: /items
  post "/boxes/:box_id/items" do
    if !params[:item].empty? && !params[:item][:name].empty?
      @user = current_user
      @box
      @item = item.create(params[:item])
      @user.items << @item

      redirect "/items/#{@item.id}"
    else
      redirect "/items/new"
    end
  end

  # GET: /items/5
  get "/boxes/:box_id/items/:id" do
    if !logged_in?
      redirect '/login'
    else
      @item = item.find_by(id: params[:id])
      if !@item.nil?
        erb :"/items/show.html"
      else
        redirect "/items"
      end
    end
  end

  # GET: /items/5/edit
  get "/boxes/:box_id/items/:id/edit" do
    if !logged_in?
      redirect '/login'
    else
      @item = item.find_by(id: params[:id])
      if !@item.nil?
        erb :"/items/edit.html"
      else
        redirect "/items"
      end
    end
  end

  # PATCH: /items/5
  patch "/boxes/:box_id/items/:id" do
    if !logged_in?
      redirect '/login'
    else
      if !params[:name].empty?
        @item = item.find_by(id: params[:id])
        if !@item.nil?
          @item.update(name: params[:name])
          redirect "/items/#{@item.id}"
        else 
          redirect "/items"
        end
      else
        redirect "/items/#{params[:id]}/edit"
      end
    end
  end

  # DELETE: /items/5/delete
  delete "/boxes/:box_id/items/:id/delete" do
    if !logged_in?
      redirect '/login'
    else
      user = current_user
      item = item.find(params[:id])
      if item.user_id == user.id
        item.destroy
        redirect "/items"
      else
        redirect "/items/#{params[:id]}"
      end
    end
  end
end
