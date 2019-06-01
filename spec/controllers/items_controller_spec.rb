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

        get '/items'
        expect(page.status_code).to eq(200)
        expect(last_response.body).to include(item1.name)
        expect(last_response.body).to include(item1.description)
        expect(last_response.body).to include(item2.name)
        expect(last_response.body).to include(item2.description)
      end
    end

    context 'logged out' do
      it 'does not let a user not logged in to view items' do

        get '/items'
        expect(last_response.location).to include("/login")
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

  end
  end
end
