require 'rubygems'
require 'restfulie'

module BuySteps
  def steps
    
    def i_want?(name)
      @what.find { |desired| name[desired] }
    end
    
    When "there is a required item" do |resource|
      if resource.keys.first == "items"
        @desired = resource.items.item.find { |item| i_want?(item.name) }
      else
        false
      end
    end
    
    When "there is a basket" do |resource|
      resource.values.first.links.basket
    end
    
    When "there is a payment" do |resource|
      resource.values.first.links.payment
    end
    
    When "it is a basket" do |resource|
      resource.keys.first == "basket"
    end
    
    When "didnt create a basket" do |resource|
      @basket_resource.nil?
    end
    
    When "there are still products to buy" do |resource|
      !@what.empty?
    end
    
    Then "start again" do |resource, regex, mikyung|
      mikyung.start
    end
    
    def pick_desired
      @what.delete_if { |desired| @desired.name[desired] }
    end
    
    Then "create the basket" do |resource|
      pick_desired
      basket = {:basket => {:items => [{:id => @desired['id']}]} }
      @basket_resource = resource.items.links.basket.post! basket
    end

    Then "add to the basket" do |resource|
      pick_desired
      items = {"items" => [{:id => @desired['id']}]}
      @basket_resource = @basket_resource.basket.links.self.patch! items
    end
    
    Then "pay" do |resource|
      payment = {:payment => {:cardnumber => "4850000000000001", :cardholder => "guilherme silveira", :amount => resource.basket.price}}
      resource.basket.links.payment.post! payment
    end
    
  end
end

module BuyScenario
  def scenarios
    
    When there is a required item
    And there is a basket
    But didnt create a basket
    Then create the basket
    
    When there is a required item
    And there is a basket
    Then add to the basket
    
    When it is a basket
    And there are still products to buy
    Then start again
    
    When there is a payment
    Then pay
    
  end
end

class BuyingProcess < Restfulie::Client::Mikyung::RestProcessModel
  include BuySteps, BuyScenario
  def initialize(what)
    @what = what
    steps
    scenarios
  end
  
  def completed?(resource)
    resource.keys.first == "payment"
  end
end

Restfulie::Common::Logger.logger.level = Logger::INFO
goal = BuyingProcess.new(["Rest", "Calpis"])
result = Restfulie::Mikyung.new.achieve(goal).at("http://localhost:3000/items").run
puts "Objective completed"
puts result.response.body

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  