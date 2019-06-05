require 'spec_helper'
require 'pry'

describe ItemsController do

  describe 'index action' do
    context 'logged in' do

      it 'loads the index page and shows all items for a user' do
        user1 = User.create(name: "Test", username: "becky123", password: "kittens", email: "test@test.com")
        box1 = Box.create(name: "Skiing", user_id: user1.id)
        item1 = Item.create(name: "Skis", description: "BlackCrows", box_id: box1.id)
        item2 = Item.create(name: "Poles", description: "Smith Carbon", box_id: box1.id)

        visit '/login'

        fill_in(:username, :with => "becky123")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/items'
        expect(page.status_code).to eq(200)
        expect(page.body).to include(item1.name)
        expect(page.body).to include(item1.description)
        expect(page.body).to include(item2.name)
        expect(page.body).to include(item2.description)
      end
    end

    context 'logged out' do
      it 'does not let a user not logged in to view items' do

        get '/items'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'new action' do
    context 'logged in' do
      it 'lets the user view new item form if logged in' do
        user1 = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/items/new'
        expect(page.status_code).to eq(200)
      end

      it 'lets the user create an item if they are logged in' do
        user1 = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box1 = Box.create(name: "Skiing")
        user1.boxes << box1

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/items/new'

        find('#boxes').find(:xpath, 'option[1]').select_option
        fill_in(:name, with: "Skis")
        fill_in(:description, with: "Blackcrows")
        click_button 'submit'

        item = Item.find_by(name: "Skis", box_id: box1.id)
        expect(item).to be_instance_of(Item)
        expect(page.status_code).to eq(200)

      end

      it 'does not let a user create a blank item' do
        user1 = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box1 = Box.create(name: "Skiing")
        user1.boxes << box1

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/items/new'

        find('#boxes').find(:xpath, 'option[1]').select_option
        fill_in(:name, with: "")
        fill_in(:description, with: "Blackcrows")
        click_button 'submit'

        item = Item.find_by(name: "", box_id: box1.id)
        expect(item).to be(nil)
        expect(page.current_path).to eq("/items/new")
      end

    end

    context 'logged out' do
      it 'does not let a user create an item if they are not logged in' do
        get '/items/new'

        expect(last_response.location).to include("/login")
      end
    end
  end


  describe 'show action' do
    context 'logged in' do
      it 'lets the user view an item' do
        user1 = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box1 = Box.create(name: "Skiing", user_id: 1)
        item1 = Item.create(name: "Skis", description: "Atomic Skis", box_id: 1)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "/items/#{item1.id}"
        expect(page.status_code).to eq(200)
        expect(page.body).to include(item1.name)
        expect(page.body).to include(item1.description)
        expect(page.body).to include("Edit Item")
        expect(page.body).to include("Delete Item")
      end
    end

    context 'logged out' do
      it 'does not let a user view an item if they are not logged in' do
        item1 = Item.create(name: "Skis", description: "Atomic Skis", box_id: 1)
        get "/items/#{item1.id}"

        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'edit action' do
    context 'logged in' do
      it 'lets the user view edit form for their own item' do
        user1 = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box1 = Box.create(name: "Skiing", user_id: 1)
        item1 = Item.create(name: "Skis", description: "Atomic Skis", box_id: 1)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "/items/#{item1.id}/edit"
        expect(page.status_code).to eq(200)
        expect(page.body).to include(item1.name)
      end

      it 'lets the user edit the name, description and box of their own item' do
        user1 = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box1 = Box.create(name: "Skiing", user_id: 1)
        box2 = Box.create(name: "Snowboarding", user_id: 1)
        item1 = Item.create(name: "Skis", description: "Atomic Skis", box_id: 1)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit "/items/#{item1.id}/edit"
        find('#boxes').find(:xpath, 'option[2]').select_option
        fill_in(:name, :with => "Snowboarding")
        fill_in(:description, :with => "Salomon Super8")
        click_button 'submit'

        expect(Item.find_by(name: "Snowboarding", description: "Salomon Super8", box_id: 2)).to be_instance_of(Item)
        expect(Item.find_by(name: "Skiing", description: "Atomic Skis", box_id: 1)).to be(nil)
      end

      it 'does not let the user edit an item to have a blank name' do
        user1 = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box1 = Box.create(name: "Skiing", user_id: 1)
        item1 = Item.create(name: "Skis", description: "Atomic Skis", box_id: 1)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit "/items/#{item1.id}/edit"
        fill_in(:name, :with => "")
        click_button 'submit'

        expect(Item.find_by(name: "Skis", description: "Atomic Skis", box_id: 1)).to be_instance_of(Item)
        expect(Item.find_by(name: "", description: "Atomic Skis", box_id: 1)).to be(nil)
        expect(page.current_path).to eq("/items/#{item1.id}/edit")
      end

      it 'does not let the user edit an item that does not belong to them' do
        user1 = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        user2 = User.create(:name => "Tester", :username => "jenny567", :email => "planetz@aol.com", :password => "kittens")
        box1 = Box.create(name: "Skiing", user_id: 1)
        item1 = Item.create(name: "Skis", description: "Atomic Skis", box_id: 1)

        visit '/login'

        fill_in(:username, :with => "jenny567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit "/items/#{item1.id}/edit"

        expect(page.current_path).to eq('/items')
      end
    end

    context 'logged out' do
      it 'does not let a user view the edit form if they are not logged in' do
        item1 = Item.create(name: "Skis", description: "Atomic Skis", box_id: 1)

        get "/items/1/edit"

        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'delete action' do
    context 'logged in' do
      it 'lets the user delete their own item' do
        user1 = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box1 = Box.create(name: "Skiing", user_id: 1)
        item1 = Item.create(name: "Skis", description: "Atomic Skis", box_id: 1)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit "/items/#{item1.id}"
        click_button 'Delete Item'

        expect(page.status_code).to eq(200)
        expect(Item.find_by(id: item1.id)).to be(nil)
      end

      it 'does not let a user delete an item they did not create' do
        user1 = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        user2 = User.create(:name => "Tester", :username => "jenny567", :email => "starz@aol.com", :password => "kittens")
        box1 = Box.create(name: "Skiing", user_id: 1)
        item1 = Item.create(name: "Skis", description: "Atomic Skis", box_id: 1)

        visit '/login'

        fill_in(:username, :with => "jenny567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit "/items/#{item1.id}"
        click_button 'Delete Item'

        expect(page.current_path).to include("/items")
        expect(Item.find_by(id: item1.id)).to be_instance_of(Item)

      end
    end
  end

end
