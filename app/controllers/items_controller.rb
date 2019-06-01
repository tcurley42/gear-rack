class ItemsController < ApplicationController

  # GET: /items
  get "/items" do
    if !logged_in?
      redirect '/login'
    else
      @user = current_user
      erb :"/items/index.html"
    end
  end

  # GET: /items/new
  get "/items/new" do
    if logged_in?
      @user = current_user
      erb :"/items/new.html"
    else
      redirect '/login'
    end
  end

  # POST: /items
  post "/items" do
    if !params[:item].empty? && !params[:item][:name].empty?
      @user = current_user
      @item = Item.create(params[:item])

      redirect "/items/#{@item.id}"
    else
      redirect "/items/new"
    end
  end

  # GET: /items/5
  get "/items/:id" do
    if !logged_in?
      redirect '/login'
    else
      @item = Item.find_by(id: params[:id])
      if !@item.nil?
        erb :"/items/show.html"
      else
        redirect "/items"
      end
    end
  end

  # GET: /items/5/edit
  get "/items/:id/edit" do
    if !logged_in?
      redirect '/login'
    else
      @item = Item.find_by(id: params[:id])
      if !@item.nil?
        erb :"/items/edit.html"
      else
        redirect "/items"
      end
    end
  end

  # PATCH: /items/5
  patch "/items/:id" do
    if !logged_in?
      redirect '/login'
    else
      if !params[:name].empty?
        @item = Item.find_by(id: params[:id])
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
  delete "/items/:id/delete" do
    if !logged_in?
      redirect '/login'
    else
      user = current_user
      item = Item.find(params[:id])
      if item.user_id == user.id
        item.destroy
        redirect "/items"
      else
        redirect "/items/#{params[:id]}"
      end
    end
  end
end
