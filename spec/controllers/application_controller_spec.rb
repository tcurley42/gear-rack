require 'spec_helper'
require 'pry'

describe ApplicationController do

  describe "Homepage" do
    it 'loads the homepage' do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome to Gear Rack")
    end
  end

  describe "Signup Page" do

    it 'loads the signup page' do
      get '/signup'
      expect(last_response.status).to eq(200)
    end

    it 'signup directs user to gear rack index' do
      params = {
          :name => "Test User",
          :username => "skittles123",
          :email => "skittles@aol.com",
          :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include("/home")
    end

    it 'does not let a user sign up without a name' do
      params = {
          :name => "",
          :username => "skittles123",
          :email => "skittles@aol.com",
          :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without a username' do
      params = {
          :name => "Test User",
          :username => "",
          :email => "skittles@aol.com",
          :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without an email' do
      params = {
          :name => "Test User",
          :username => "skittles123",
          :email => "",
          :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without a password' do
      params = {
          :name => "Test User",
          :username => "skittles123",
          :email => "skittles@aol.com",
          :password => ""
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'creates a new user and logs them in on valid submission and does not let a logged in user view the signup page' do
      params = {
          :name => "Test User",
          :username => "skittles123",
          :email => "skittles@aol.com",
          :password => "rainbows"
      }
      post '/signup', params
      get '/signup'
      expect(last_response.location).to include('/home')
    end
  end

  describe "login" do
    it 'loads the login page' do
      get '/login'
      expect(last_response.status).to eq(200)
    end

    it 'loads the gear index after login' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome,")
    end

    it 'does not let user view login page if already logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      get '/login'
      expect(last_response.location).to include("/home")
    end
  end

  describe "logout" do
    it "lets a user logout if they are already logged in" do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      get '/logout'
      expect(last_response.location).to include("/login")
    end

    it 'does not let a user logout if not logged in' do
      get '/logout'
      expect(last_response.location).to include("/")
    end

    it 'does not load /home if user not logged in' do
      get '/home'
      expect(last_response.location).to include("/login")
    end

    it 'does load /home if user is logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")


      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      expect(page.current_path).to eq('/home')
    end
  end

  describe 'user show page' do
    it 'shows all a single users gear boxes' do
      user = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
      box1 = Box.create(:name => "Snowboarding", :user_id => user.id)
      box2 = Tweet.create(:name => "Skiing", :user_id => user.id)
      get "/users/#{user.slug}"

      expect(last_response.body).to include("Snowboarding")
      expect(last_response.body).to include("Skiing")

    end
  end

  describe 'index action' do
    context 'logged in' do
      it 'lets a user view the boxes index if logged in' do
        user1 = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box1 = Box.create(:name => "Snowboarding", :user_id => user1.id)

        user2 = User.create(:name => "Tester", :username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        box2 = Box.create(:content => "Skiing", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "/boxes"
        expect(page.body).to include(box1.content)
        expect(page.body).to include(box2.content)
      end
    end

    context 'logged out' do
      it 'does not let a user view the boxes index if not logged in' do

        get '/boxes'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'new action' do
    context 'logged in' do
      it 'lets user view new box form if logged in' do
        user = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/boxes/new'
        expect(page.status_code).to eq(200)
      end

      it 'lets user create a box if they are logged in' do
        user = User.create(:name => "test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/boxes/new'
        fill_in(:name, :with => "Snowboarding")
        click_button 'submit'

        user = User.find_by(:username => "becky567")
        box = Box.find_by(:name => "Snowboarding", :user_id => user.id)
        expect(box).to be_instance_of(Box)
        expect(box.user_id).to eq(user.id)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user create a box from another user' do
        user = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        user2 = User.create(:anem => "Test2", :username => "silverstallion", :email => "silver@aol.com", :password => "horses")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/boxes/new'

        fill_in(:name, :with => "Skiing")
        click_button 'submit'

        user = User.find_by(:id=> user.id)
        user2 = User.find_by(:id => user2.id)
        box = Box.find_by(:name => "Skiing", :user_id => user.id)
        expect(box).to be_instance_of(Box)
        expect(box.user_id).to eq(user.id)
        expect(box.user_id).not_to eq(user2.id)
      end

      it 'does not let a user create a blank box' do
        user = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/boxes/new'

        fill_in(:name, :with => "")
        click_button 'submit'

        expect(Box.find_by(:name => "")).to eq(nil)
        expect(page.current_path).to eq("/boxes/new")
      end
    end

    context 'logged out' do
      it 'does not let user view new box form if not logged in' do
        get '/boxes/new'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'show action' do
    context 'logged in' do
      it 'displays a single box' do

        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box = Box.create(:name => "Climbing", :user_id => user.id)
        item = Item.create(:name => "Harness", :description => "Orange blah blah harness")
        box.items << item

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit "/boxes/#{box.id}"
        expect(page.status_code).to eq(200)
        expect(page.body).to include("Delete Box")
        expect(page.body).to include(box.name)
        expect(page.body).to include("Edit Box")
        expect(page.body).to include(item.name)
      end
    end

    context 'logged out' do
      it 'does not let a user view a box' do
        user = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box = Box.create(:name => "Climbing", :user_id => user.id)
        get "/boxes/#{box.id}"
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'edit action' do
    context "logged in" do
      it 'lets a user view box edit form if they are logged in' do
        user = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box = Box.create(:name => "Skiing", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/boxes/1/edit'
        expect(page.status_code).to eq(200)
        expect(page.body).to include(box.content)
      end

      it 'does not let a user edit a box they did not create' do
        user1 = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box1 = Box.create(:name => "Climbing", :user_id => user1.id)

        user2 = User.create(:name => "Test2", :username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        box2 = Box.create(:name => "Skiing", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "/boxes/#{box2.id}/edit"
        expect(page.current_path).to include('/boxes')
      end

      it 'lets a user edit their own box if they are logged in' do
        user = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box = Box.create(:name => "Climbing", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/boxes/1/edit'

        fill_in(:name, :with => "Skiing")

        click_button 'submit'
        expect(Box.find_by(id: box.id, sport: "Skiing")).to be_instance_of(Box)
        expect(Box.find_by(id: box.id, sport: "Climbing")).to eq(nil)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user edit a text with blank name' do
        user = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box = Box.create(:name => "Skiing", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/boxes/1/edit'

        fill_in(:name, :with => "")

        click_button 'submit'
        expect(Box.find(box.id)).to be(nil)
        expect(page.current_path).to eq("/boxes/1/edit")
      end
    end

    context "logged out" do
      it 'does not load -- instead redirects to login' do
        get '/boxes/1/edit'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'delete action' do
    context "logged in" do
      it 'lets a user delete their own box if they are logged in' do
        user = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box = Box.create(:name => "Skiing", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit 'boxes/1'
        click_button "Delete Box"
        expect(page.status_code).to eq(200)
        expect(Box.find(box.id)).to eq(nil)
      end

      it 'does not let a user delete a box they did not create' do
        user1 = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box1 = Box.create(:name => "Skiing", :user_id => user1.id)

        user2 = User.create(:name => "Test2", :username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        box2 = Box.create(:name => "Snowboarding", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "boxes/#{box2.id}"
        click_button "Delete Box"
        expect(page.status_code).to eq(200)
        expect(Box.find(box2.id)).to be_instance_of(Box)
        expect(page.current_path).to include('/boxes')
      end
    end

    context "logged out" do
      it 'does not load let user delete a box if not logged in' do
        box = Box.create(:name => "Skiing", :user_id => 1)
        visit '/boxes/1'
        expect(page.current_path).to eq("/login")
      end
    end
  end
end
